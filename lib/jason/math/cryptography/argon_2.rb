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

        def initialize(
          salt,                  # Bytes (8..2^32-1)    Salt (16 bytes recommended for password hashing)
          parallelism,
          tag_length,            # Number (4..2^32-1)   Desired number of returned bytes
          memory_size,           # Number (8p..2^32-1)  Amount of memory (in kibibytes) to use
          iterations,            # Number (1..2^32-1)   Number of iterations to perform
          key = '',              # Bytes (0..2^32-1)    Optional key (Errata: PDF says 0..32 bytes, RFC says 0..2^32 bytes)
          hash_type = :argon2id  # Number (0=Argon2d, 1=Argon2i, 2=Argon2id)
        )
          @salt = salt
          @parallelism = parallelism
          @tag_length = tag_length
          @memory_size = memory_size
          @iterations = iterations
          @key = key
          @hash_type = hash_type

          @blake2b = Blake.new(:'2b', 64)
        end

        def derive(password, associated_data = '')
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
          puts "pre-hashing digest:"
          pp h0.byte_string_to_hex

          @block_count = if @memory_size >= 2 * SYNC_POINTS * @parallelism
                           (@memory_size / (SYNC_POINTS * @parallelism)) * (SYNC_POINTS * @parallelism)
                         else
                           2 * SYNC_POINTS * @parallelism
                         end
          @column_count = @block_count / @parallelism
          @segment_length = @column_count / SYNC_POINTS
          @address_generator = nil

          blocks = []

          (0..(@parallelism - 1)).each do |lane|
            blocks << []
            (0..(@column_count - 1)).each do |column|
              blocks[lane] << "\x00" * 1024
            end
          end

          (0..(@parallelism - 1)).map do |lane|
            blocks[lane][0] = hash(h0 + [0].pack('V1') + [lane].pack('V1'), 1024)
            blocks[lane][1] = hash(h0 + [1].pack('V1') + [lane].pack('V1'), 1024)
          end

          (0..0).each do |pass|
          # (0..(@iterations - 1)).each do |pass|
            (0..(SYNC_POINTS - 1)).each do |slice|
              (0..(@parallelism - 1)).each do |lane| # as the code implies, this block can be parallelized
                (0..(@segment_length - 1)).each do |index_in_segment|
                  column = slice * @segment_length + index_in_segment
                  next if pass.zero? && column < 2

                  i, j = get_block_indexes(blocks, lane, column, pass)
                  pp({
                       lane: lane,
                       column: column,
                       slice: slice,
                       i: i,
                       j: j,
                       index_in_segment: index_in_segment
                     })
                  blocks[lane][column] = if pass.zero?
                                           compress(blocks[lane][(column - 1) % @column_count], blocks[i][j])
                                         else
                                           Utility.xor(
                                             blocks[lane][column],
                                             compress(blocks[lane][(column - 1) % @column_count], blocks[i][j])
                                           )
                                         end
                end
              end
            end

            puts "After pass #{pass}:"
            (0..(@parallelism - 1)).each do |lane|
              (0..(@column_count - 1)).each do |column|
                blocks[lane][column].unpack('Q<128').each_with_index do |block, index|
                  puts "block #{lane * @column_count + column} [#{index}] #{[block].pack('Q>1').byte_string_to_hex}"
                end
              end
            end
          end

          c = ZERO
          (0..(@parallelism - 1)).each do |lane|
            c = Utility.xor(c, blocks[lane][@column_count - 1])
          end

          hash(c, @tag_length)
        end

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
          r.times { v << @blake2b.digest(v.last) }

          bytes_remaining = digest_length - 32 * (r + 1)
          @blake2b.output_length = bytes_remaining unless bytes_remaining == 64
          digest = v.map { |block| block[0..31] }.join + @blake2b.digest(v.last)
          @blake2b.output_length = 64 unless bytes_remaining == 64

          digest
        end

        def compress(x, y)
          r_string = Utility.xor(x, y)

          r = r_string.unpack('Q<128')
          # might have to swap all pairs ?
          # (0..63).each do |i|
          #   temp = r[2 * i]
          #   r[2 * i] = r[2 * i + 1]
          #   r[2 * i + 1] = temp
          # end

          pp r
          q = [0] * 128
          z = [0] * 128

          [[r, q], [q, z]].each do |outv, inv|
            (0..7).each { |i| @blake2b.send(:round, outv[(i * 16)..((i + 1) * 16 - 1)],
                                            SIXTEEN_ZEROES, SIXTEEN_ZEROES, mka: true) }

            (0..7).each do |i| # rubocop:disable Style/CombinableLoops
              (0..7).each do |j|
                inv[i * 16 + j * 2] = outv[j * 16 + i * 2]
                inv[i * 16 + j * 2 + 1] = outv[j * 16 + i * 2 + 1]
              end
            end
          end

          Utility.xor(r_string, z.pack('Q<128'))
        end

        def get_block_indexes(blocks, lane, column, pass)
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

          puts "#{j1.to_s(16)}, #{j2.to_s(16)}"
          l = slice.zero? && pass.zero? ? lane : j2 % @parallelism
          w = reference_count(lane, column % @segment_length, pass, l == lane) # this is |R|, in case you can't follow

          # To avoid floating-point computation, we use the following integer approximation:
          # x = J1^2 / 2^32;
          # y = (|R| ∗ x)/2
          # 32;
          # z = |R| − 1 − y.
          x = ((j1 * j1) & MASK64) >> 32
          y = ((w * x) & MASK64) >> 32
          z = w - 1 - y

          origin = 0
          origin = ((slice + 1) % SYNC_POINTS) * @segment_length unless pass.zero?

          [l, origin + z]
        end

        # Then we determine the set of indices R that can be referenced for given [i][j] according to the following
        # rules:
        # 1. If l is the current lane, then R includes all blocks computed in this lane, that are not overwritten
        # yet, excluding B[i][j − 1].
        # 2. If l is not the current lane, then R includes all blocks in the last S −1 = 3 segments computed and
        # finished in lane l. If B[i][j] is the first block of a segment, then the very last block from R is excluded.
        def reference_count(lane, slice, pass, same_lane)
          pass_val = pass.zero? ? slice * @segment_length : @column_count - @segment_length
          same_lane ? pass_val + (lane - 1) : pass_val + (lane.zero? ? -1 : 0) # rubocop:disable Style/NestedTernaryOperator
        end

        def compute_jn_i(lane, slice, pass)
          @z ||= [pass].pack('Q<1') +
                 [lane].pack('Q<1') +
                 [slice].pack('Q<1') +
                 [@block_count].pack('Q<1') +
                 [@iterations].pack('Q<1') +
                 [HASH_TYPES[@hash_type]].pack('Q<1')

          @address_generator ||= Enumerator.new do |yielder|
            i = 1
            loop do
              yielder << compress(ZERO, compress(ZERO, @z + [i].pack('Q<1') + ZERO[0..967]))
              i += 1
            end
          end

          @addresses = @address_generator.next

          [0, 0]
        end

        def compute_jn_d(blocks, lane, column)
          puts "taking jn from #{lane}, #{column}"
          [blocks[lane][column - 1][4..7].unpack1('V1'), blocks[lane][column - 1][0..3].unpack1('V1')]
        end
      end
    end
  end
end
