# frozen_string_literal: true

module Jason
  module Math
    module Cryptography
      # Argon2
      class Argon2
        VERSION = 0x13
        SYNC_POINTS = 4
        ZERO = ("\x00" * 1024).freeze
        SIXTEEN_ZEROES = [0] * 16

        MASK64 = 0xffffffffffffffff
        MASK32 = 0xffffffff

        HASH_TYPES = {
          argon2d: 0,
          argon2i: 1,
          argon2id: 2
        }.freeze

        def initialize( # rubocop:disable Metrics/ParameterLists
          parallelism,
          tag_length,
          memory_size,
          iterations,
          key = '',
          hash_type = :argon2id
        )
          @parallelism = parallelism
          @tag_length = tag_length
          @memory_size = memory_size
          @iterations = iterations
          @key = key
          @hash_type = hash_type

          @blake2b = Blake.new(:'2b', 64)
        end

        def derive(password, salt, associated_data = '') # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength
          @block_count = if @memory_size >= 2 * SYNC_POINTS * @parallelism
                           (@memory_size / (SYNC_POINTS * @parallelism)) * (SYNC_POINTS * @parallelism)
                         else
                           2 * SYNC_POINTS * @parallelism
                         end
          @salt = salt
          @column_count = @block_count / @parallelism
          @segment_length = @column_count / SYNC_POINTS
          @address_generators = {}

          @blake2b << [@parallelism].pack('V1')
          @blake2b << [@tag_length].pack('V1')
          @blake2b << [@memory_size].pack('V1')
          @blake2b << [@iterations].pack('V1')
          @blake2b << [VERSION].pack('V1')
          @blake2b << [HASH_TYPES[@hash_type]].pack('V1')
          @blake2b << [password.length].pack('V1')
          @blake2b << password + [@salt.length].pack('V1')
          @blake2b << @salt
          @blake2b << [@key.length].pack('V1')
          @blake2b << @key
          @blake2b << [associated_data.length].pack('V1')
          @blake2b << associated_data

          h0 = @blake2b.digest

          # initial state
          blocks = []
          @parallelism.times do |lane|
            blocks << [
              hash(h0 + [0].pack('V1') + [lane].pack('V1'), 1024),
              hash(h0 + [1].pack('V1') + [lane].pack('V1'), 1024)
            ]
          end

          # the meat
          @iterations.times do |pass|
            SYNC_POINTS.times do |slice|
              @parallelism.times do |lane| # as the code implies, this block can be parallelized
                @segment_length.times do |index_in_segment|
                  column = slice * @segment_length + index_in_segment
                  next if pass.zero? && column < 2

                  i, j = get_reference_index(blocks, lane, column, pass)

                  previous_block = blocks[lane][(column - 1) % @column_count]
                  reference_block = blocks[i][j]

                  blocks[lane][column] = if pass.zero?
                                           compress(previous_block, reference_block)
                                         else
                                           Utility.xor(
                                             blocks[lane][column],
                                             compress(previous_block, reference_block)
                                           )
                                         end
                end
              end
            end
          end

          # reduce down to a single value
          c = ZERO
          (0..(@parallelism - 1)).each do |lane|
            c = Utility.xor(c, blocks[lane][@column_count - 1])
          end

          hash(c, @tag_length)
        end

        private

        def hash(message, digest_length)
          initial_message = [digest_length].pack('V1') + message

          @blake2b.output_length = digest_length if digest_length < 64
          initial_digest = @blake2b.digest(initial_message)
          if digest_length <= 64
            @blake2b.output_length = 64 unless digest_length == 64
            return initial_digest
          end

          r = (digest_length.to_f / 32).ceil - 2
          v = [initial_digest]
          (r - 1).times { v << @blake2b.digest(v.last) }

          bytes_remaining = digest_length - 32 * r
          @blake2b.output_length = bytes_remaining unless bytes_remaining == 64
          digest = v.map { |block| block[0..31] }.join + @blake2b.digest(v.last)
          @blake2b.output_length = 64 unless bytes_remaining == 64

          digest
        end

        def compress(x, y)
          r_string = Utility.xor(x, y)
          r = r_string.unpack('Q<128')

          q = []
          z = [nil] * 128

          8.times do |i|
            range = (i * 16)..((i + 1) * 16 - 1)
            chunk = r[range]
            @blake2b.send(:round, chunk, SIXTEEN_ZEROES, SIXTEEN_ZEROES, mka: true)
            q += chunk
          end

          8.times do |i|
            chunk = q.select.with_index { |_, j| j % 16 == 2 * i || (j - 1) % 16 == 2 * i }
            @blake2b.send(:round, chunk, SIXTEEN_ZEROES, SIXTEEN_ZEROES, mka: true)

            8.times do |j|
              z[j * 16 + 2 * i] = chunk[2 * j]
              z[j * 16 + 2 * i + 1] = chunk[2 * j + 1]
            end
          end

          Utility.xor(r_string, z.pack('Q<128'))
        end

        def get_reference_index(blocks, lane, column, pass) # rubocop:disable Metrics/CyclomaticComplexity
          slice = column / @segment_length
          j1, j2 = case @hash_type
                   when :argon2i
                     compute_jn_i(lane, slice, pass)
                   when :argon2d
                     compute_jn_d(blocks, lane, column)
                   when :argon2id
                     if pass.zero? && slice < SYNC_POINTS / 2
                       compute_jn_i(lane, slice, pass)
                     else
                       compute_jn_d(blocks, lane, column)
                     end
                   end

          l = slice.zero? && pass.zero? ? lane : j2 % @parallelism
          w = reference_count(pass, slice, column % @segment_length, l == lane) # this is |R|, in case you can't follow

          # To avoid floating-point computation, we use the following integer approximation:
          # x = J1^2 / 2^32;
          # y = (|R| ∗ x)/2
          # 32;
          # z = |R| − 1 − y.
          x = ((j1 * j1) & MASK64) >> 32
          y = ((w * x) & MASK64) >> 32
          z = w - 1 - y

          origin = pass.zero? ? 0 : ((slice + 1) % SYNC_POINTS) * @segment_length

          [l, (origin + z) % @column_count]
        end

        # Then we determine the set of indices R that can be referenced for given [i][j] according to the following
        # rules:
        # 1. If l is the current lane, then R includes all blocks computed in this lane, that are not overwritten
        # yet, excluding B[i][j − 1].
        # 2. If l is not the current lane, then R includes all blocks in the last S −1 = 3 segments computed and
        # finished in lane l. If B[i][j] is the first block of a segment, then the very last block from R is excluded.
        def reference_count(pass, slice, index_in_segment, same_lane)
          index_count = pass.zero? ? slice * @segment_length : @column_count - @segment_length
          same_lane ? index_count + (index_in_segment - 1) : index_count + (index_in_segment.zero? ? -1 : 0) # rubocop:disable Style/NestedTernaryOperator
        end

        def compute_jn_i(lane, slice, pass)
          z = [pass].pack('Q<1') +
              [lane].pack('Q<1') +
              [slice].pack('Q<1') +
              [@block_count].pack('Q<1') +
              [@iterations].pack('Q<1') +
              [HASH_TYPES[@hash_type]].pack('Q<1')

          generator_key = [lane, slice, pass]
          @address_generators[generator_key] ||= Enumerator.new do |yielder|
            i = 1
            loop do
              addresses = compress(ZERO, compress(ZERO, z + [i].pack('Q<1') + ZERO[0..967])).unpack('Q<128')
              128.times { |j| yielder << [addresses[j] & MASK32, addresses[j] >> 32] }
              i += 1
            end
          end

          @address_generators[generator_key].next
        end

        def compute_jn_d(blocks, lane, column)
          previous_column = (column - 1) % @column_count
          [blocks[lane][previous_column][0..3].unpack1('V1'), blocks[lane][previous_column][4..7].unpack1('V1')]
        end
      end
    end
  end
end
