# frozen_string_literal: true

require 'openssl'

module Jason
  module Math
    module Cryptography
      module SymmetricKey
        # Rijndael's algorithm
        class AdvancedEncryptionStandard # rubocop:disable Metrics/ClassLength
          attr_writer :initialization_vector

          # rubocop:disable Naming/VariableNumber
          MODE_DETAILS = {
            cbc_128: {
              mode: :cbc,
              bits: 128,
              rounds: 10,
              key_size: 4, # in 4-byte words
              openssl_algorithm: 'aes-128-cbc'
            }.freeze,
            cbc_192: {
              mode: :cbc,
              bits: 192,
              rounds: 12,
              key_size: 6, # in 4-byte words
              openssl_algorithm: 'aes-192-cbc'
            }.freeze,
            cbc_256: {
              mode: :cbc,
              bits: 256,
              rounds: 14,
              key_size: 8, # in 4-byte words
              openssl_algorithm: 'aes-256-cbc'
            }.freeze,
            cfb_128: {
              mode: :cfb,
              bits: 128,
              rounds: 10,
              key_size: 4, # in 4-byte words
              openssl_algorithm: 'aes-128-cfb'
            }.freeze,
            cfb_192: {
              mode: :cfb,
              bits: 192,
              rounds: 12,
              key_size: 6, # in 4-byte words
              openssl_algorithm: 'aes-192-cfb'
            }.freeze,
            cfb_256: {
              mode: :cfb,
              bits: 256,
              rounds: 14,
              key_size: 8, # in 4-byte words
              openssl_algorithm: 'aes-256-cfb'
            }.freeze,
            ctr_128: {
              mode: :ctr,
              bits: 128,
              rounds: 10,
              key_size: 4, # in 4-byte words
              openssl_algorithm: 'aes-128-ctr'
            }.freeze,
            ctr_192: {
              mode: :ctr,
              bits: 192,
              rounds: 12,
              key_size: 6, # in 4-byte words
              openssl_algorithm: 'aes-192-ctr'
            }.freeze,
            ctr_256: {
              mode: :ctr,
              bits: 256,
              rounds: 14,
              key_size: 8, # in 4-byte words
              openssl_algorithm: 'aes-256-ctr'
            }.freeze,
            ecb_128: {
              mode: :ecb,
              bits: 128,
              rounds: 10,
              key_size: 4, # in 4-byte words
              openssl_algorithm: 'aes-128-ecb'
            }.freeze,
            ecb_192: {
              mode: :ecb,
              bits: 192,
              rounds: 12,
              key_size: 6, # in 4-byte words
              openssl_algorithm: 'aes-192-ecb'
            }.freeze,
            ecb_256: {
              mode: :ecb,
              bits: 256,
              rounds: 14,
              key_size: 8, # in 4-byte words
              openssl_algorithm: 'aes-256-ecb'
            }.freeze,
            gcm_128: {
              mode: :gcm,
              bits: 128,
              rounds: 10,
              key_size: 4, # in 4-byte words
              openssl_algorithm: 'aes-128-gcm'
            }.freeze,
            gcm_192: {
              mode: :gcm,
              bits: 192,
              rounds: 12,
              key_size: 6, # in 4-byte words
              openssl_algorithm: 'aes-192-gcm'
            }.freeze,
            gcm_256: {
              mode: :gcm,
              bits: 256,
              rounds: 14,
              key_size: 8, # in 4-byte words
              openssl_algorithm: 'aes-256-gcm'
            }.freeze,
            ofb_128: {
              mode: :ofb,
              bits: 128,
              rounds: 10,
              key_size: 4, # in 4-byte words
              openssl_algorithm: 'aes-128-ofb'
            }.freeze,
            ofb_192: {
              mode: :ofb,
              bits: 192,
              rounds: 12,
              key_size: 6, # in 4-byte words
              openssl_algorithm: 'aes-192-ofb'
            }.freeze,
            ofb_256: {
              mode: :ofb,
              bits: 256,
              rounds: 14,
              key_size: 8, # in 4-byte words
              openssl_algorithm: 'aes-256-ofb'
            }.freeze
          }.freeze
          # rubocop:enable Naming/VariableNumber

          R_CON = [
            0,
            0x01000000,
            0x02000000,
            0x04000000,
            0x08000000,
            0x10000000,
            0x20000000,
            0x40000000,
            0x80000000,
            0x1b000000,
            0x36000000
          ].freeze

          S_BOX = [
            0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76,
            0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0,
            0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15,
            0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75,
            0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84,
            0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf,
            0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8,
            0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2,
            0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73,
            0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb,
            0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79,
            0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08,
            0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a,
            0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e,
            0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf,
            0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16
          ].freeze

          INVERSE_S_BOX = [
            0x52, 0x09, 0x6a, 0xd5, 0x30, 0x36, 0xa5, 0x38, 0xbf, 0x40, 0xa3, 0x9e, 0x81, 0xf3, 0xd7, 0xfb,
            0x7c, 0xe3, 0x39, 0x82, 0x9b, 0x2f, 0xff, 0x87, 0x34, 0x8e, 0x43, 0x44, 0xc4, 0xde, 0xe9, 0xcb,
            0x54, 0x7b, 0x94, 0x32, 0xa6, 0xc2, 0x23, 0x3d, 0xee, 0x4c, 0x95, 0x0b, 0x42, 0xfa, 0xc3, 0x4e,
            0x08, 0x2e, 0xa1, 0x66, 0x28, 0xd9, 0x24, 0xb2, 0x76, 0x5b, 0xa2, 0x49, 0x6d, 0x8b, 0xd1, 0x25,
            0x72, 0xf8, 0xf6, 0x64, 0x86, 0x68, 0x98, 0x16, 0xd4, 0xa4, 0x5c, 0xcc, 0x5d, 0x65, 0xb6, 0x92,
            0x6c, 0x70, 0x48, 0x50, 0xfd, 0xed, 0xb9, 0xda, 0x5e, 0x15, 0x46, 0x57, 0xa7, 0x8d, 0x9d, 0x84,
            0x90, 0xd8, 0xab, 0x00, 0x8c, 0xbc, 0xd3, 0x0a, 0xf7, 0xe4, 0x58, 0x05, 0xb8, 0xb3, 0x45, 0x06,
            0xd0, 0x2c, 0x1e, 0x8f, 0xca, 0x3f, 0x0f, 0x02, 0xc1, 0xaf, 0xbd, 0x03, 0x01, 0x13, 0x8a, 0x6b,
            0x3a, 0x91, 0x11, 0x41, 0x4f, 0x67, 0xdc, 0xea, 0x97, 0xf2, 0xcf, 0xce, 0xf0, 0xb4, 0xe6, 0x73,
            0x96, 0xac, 0x74, 0x22, 0xe7, 0xad, 0x35, 0x85, 0xe2, 0xf9, 0x37, 0xe8, 0x1c, 0x75, 0xdf, 0x6e,
            0x47, 0xf1, 0x1a, 0x71, 0x1d, 0x29, 0xc5, 0x89, 0x6f, 0xb7, 0x62, 0x0e, 0xaa, 0x18, 0xbe, 0x1b,
            0xfc, 0x56, 0x3e, 0x4b, 0xc6, 0xd2, 0x79, 0x20, 0x9a, 0xdb, 0xc0, 0xfe, 0x78, 0xcd, 0x5a, 0xf4,
            0x1f, 0xdd, 0xa8, 0x33, 0x88, 0x07, 0xc7, 0x31, 0xb1, 0x12, 0x10, 0x59, 0x27, 0x80, 0xec, 0x5f,
            0x60, 0x51, 0x7f, 0xa9, 0x19, 0xb5, 0x4a, 0x0d, 0x2d, 0xe5, 0x7a, 0x9f, 0x93, 0xc9, 0x9c, 0xef,
            0xa0, 0xe0, 0x3b, 0x4d, 0xae, 0x2a, 0xf5, 0xb0, 0xc8, 0xeb, 0xbb, 0x3c, 0x83, 0x53, 0x99, 0x61,
            0x17, 0x2b, 0x04, 0x7e, 0xba, 0x77, 0xd6, 0x26, 0xe1, 0x69, 0x14, 0x63, 0x55, 0x21, 0x0c, 0x7d
          ].freeze

          def initialize(mode, key, use_openssl: false) # rubocop:disable Metrics/MethodLength
            mode_details = MODE_DETAILS[mode]

            @use_openssl = use_openssl
            if use_openssl
              @openssl_algorithm = mode_details[:openssl_algorithm]
              @key = key
            else
              @mode = mode_details[:mode]
              @bits = mode_details[:bits]
              @rounds = mode_details[:rounds]
              @key_size = mode_details[:key_size]
              @block_size = 16 # bytes
              @initialization_vector = "\x00" * @block_size
              @counter_limit = 2**(@block_size * 8)
              @key_schedule = expand_key(key)
              auth_key = encrypt_ecb(@initialization_vector)[0..15]

              if @mode.to_s.end_with?('gcm')
                @gcm_multiplication_table = [] # for 8-bit
                16.times do |i|
                  row = []
                  256.times do |j|
                    row << galois_multiply_f_2_128(auth_key, j << (8 * i))
                  end
                  @gcm_multiplication_table << row
                end
              end
            end
          end

          def encrypt(clear_text, authenticated_data = nil)
            return encrypt_openssl(clear_text) if @use_openssl
            return send("encrypt_#{@mode}".to_sym, clear_text) unless @mode == :gcm

            send("encrypt_#{@mode}".to_sym, clear_text, authenticated_data)
          end

          def decrypt(cipher_text, authenticated_data = nil, tag = nil, strip_padding: true)
            return decrypt_openssl(cipher_text) if @use_openssl
            return send("decrypt_#{@mode}".to_sym, cipher_text, strip_padding: strip_padding) unless @mode == :gcm

            send("decrypt_#{@mode}".to_sym, cipher_text, authenticated_data, tag)
          end

          def generate_nonce(length = 16)
            Utility.and("\x7f#{"\xff" * (length - 1)}", SecureRandom.bytes(length))
          end

          def self.generate_key(mode)
            SecureRandom.bytes(4 * MODE_DETAILS[mode][:key_size])
          end

          def increment_initialization_vector(offset = 1)
            @initialization_vector = Utility.integer_to_byte_string(
              ((Utility.byte_string_to_integer(@initialization_vector) + offset) % @counter_limit)
            ).rjust(@block_size, "\x00")
          end

          private

          def expand_key(key)
            raise 'Invalid key length' unless key.length == @key_size * 4

            key_schedule = key.unpack('N*')

            i = @key_size
            while i < 4 * (@rounds + 1)
              temp = key_schedule[i - 1]

              if (i % @key_size).zero?
                temp = sub_word(rot_word(temp)) ^ R_CON[i / @key_size]
              elsif @key_size > 6 && i % @key_size == 4
                temp = sub_word(temp)
              end

              key_schedule << (key_schedule[i - @key_size] ^ temp)

              i += 1
            end

            key_schedule.pack('N*')
          end

          # Electronic CodeBook (ECB)

          def encrypt_ecb(clear_text)
            length = clear_text.length
            iterations = length / @block_size + 1
            cipher_text = ''.b

            iterations.times do |i|
              to_cipher = if i * @block_size < length
                            clear_text[(i * @block_size)..[(i + 1) * @block_size - 1,
                                                           length - 1].min]
                          else
                            ''.b
                          end
              to_cipher = PKCS7.pad_block(to_cipher, @block_size)
              cipher_text << cipher(to_cipher)
            end

            cipher_text
          end

          def decrypt_ecb(cipher_text, strip_padding: true)
            length = cipher_text.length

            raise 'Invalid cipher text length (must be a multiple of block size)' unless (length % @block_size).zero?

            iterations = length / @block_size
            clear_text = ''.b

            iterations.times do |i|
              clear_text << decipher(cipher_text[(i * @block_size)..((i + 1) * @block_size - 1)])
            end

            if strip_padding
              PKCS7.strip(clear_text, @block_size)
            else
              clear_text
            end
          end

          # Cipher Block Chaining (CBC)

          def encrypt_cbc(clear_text)
            length = clear_text.length
            iterations = length / @block_size + 1
            cipher_text = ''.b

            iterations.times do |i|
              to_xor = if i * @block_size < length
                         clear_text[(i * @block_size)..[(i + 1) * @block_size - 1,
                                                        length - 1].min]
                       else
                         ''.b
                       end
              to_xor = PKCS7.pad_block(to_xor, @block_size)
              to_cipher = Utility.xor(to_xor, @initialization_vector)
              @initialization_vector = cipher(to_cipher)
              cipher_text << @initialization_vector
            end

            cipher_text
          end

          def decrypt_cbc(cipher_text, strip_padding: true)
            length = cipher_text.length

            raise 'Invalid cipher text length (must be a multiple of block size)' unless (length % @block_size).zero?

            iterations = length / @block_size
            clear_text = ''.b

            iterations.times do |i|
              current_block = cipher_text[(i * @block_size)..((i + 1) * @block_size - 1)]
              clear_text << Utility.xor(decipher(current_block), @initialization_vector)
              @initialization_vector = current_block
            end

            if strip_padding
              PKCS7.strip(clear_text, @block_size)
            else
              clear_text
            end
          end

          # Cipher Feedback (CFB)

          def encrypt_cfb(clear_text)
            length = clear_text.length
            iterations = (length.to_f / @block_size).ceil
            cipher_text = ''.b

            iterations.times do |i|
              ciphered_block = cipher(@initialization_vector)
              to_xor = clear_text[(i * @block_size)..[(i + 1) * @block_size - 1, length - 1].min]
              @initialization_vector = Utility.xor(ciphered_block[0..(to_xor.length - 1)], to_xor)
              cipher_text << @initialization_vector
            end

            cipher_text
          end

          def decrypt_cfb(cipher_text, _ = nil)
            length = cipher_text.length
            iterations = (length.to_f / @block_size).ceil
            clear_text = ''.b

            iterations.times do |i|
              ciphered_block = cipher(@initialization_vector)
              @initialization_vector = cipher_text[(i * @block_size)..[(i + 1) * @block_size - 1, length - 1].min]
              clear_text << Utility.xor(ciphered_block[0..(@initialization_vector.length - 1)], @initialization_vector)
            end

            clear_text
          end

          # Output Feedback (OFB)

          def encrypt_ofb(clear_text)
            length = clear_text.length
            iterations = (length.to_f / @block_size).ceil
            cipher_text = ''.b

            iterations.times do |i|
              @initialization_vector = cipher(@initialization_vector)
              to_xor = clear_text[(i * @block_size)..[(i + 1) * @block_size - 1, length - 1].min]
              cipher_text << Utility.xor(@initialization_vector[0..(to_xor.length - 1)], to_xor)
            end

            cipher_text
          end

          def decrypt_ofb(cipher_text, _ = nil)
            length = cipher_text.length
            iterations = (length.to_f / @block_size).ceil
            clear_text = ''.b

            iterations.times do |i|
              @initialization_vector = cipher(@initialization_vector)
              to_xor = cipher_text[(i * @block_size)..[(i + 1) * @block_size - 1, length - 1].min]
              clear_text << Utility.xor(@initialization_vector[0..(to_xor.length - 1)], to_xor)
            end

            clear_text
          end

          # Counter (CTR)

          def encrypt_ctr(clear_text)
            length = clear_text.length
            iterations = (length.to_f / @block_size).ceil
            cipher_text = ''.b

            iterations.times do |i|
              ciphered_block = cipher(@initialization_vector)
              to_xor = clear_text[(i * @block_size)..[(i + 1) * @block_size - 1, length - 1].min]
              cipher_text << Utility.xor(ciphered_block[0..(to_xor.length - 1)], to_xor)
              increment_initialization_vector
            end

            cipher_text
          end

          def decrypt_ctr(cipher_text, _ = nil)
            length = cipher_text.length
            iterations = (length.to_f / @block_size).ceil
            clear_text = ''.b

            iterations.times do |i|
              ciphered_block = cipher(@initialization_vector)
              to_xor = cipher_text[(i * @block_size)..[(i + 1) * @block_size - 1, length - 1].min]
              clear_text << Utility.xor(ciphered_block[0..(to_xor.length - 1)], to_xor)
              increment_initialization_vector
            end

            clear_text
          end

          # Galois Counter (GCM)
          # for gcm, use 12 bytes of entropy to lead your IV and pad with zeros

          def encrypt_gcm(clear_text, authenticated_data)
            length = clear_text.length
            iterations = (length.to_f / @block_size).ceil
            cipher_text = ''.b

            increment_initialization_vector
            initialization_vector = @initialization_vector.dup
            increment_initialization_vector

            iterations.times do |i|
              ciphered_block = cipher(@initialization_vector)
              to_xor = clear_text[(i * @block_size)..[(i + 1) * @block_size - 1, length - 1].min]
              cipher_text << Utility.xor(ciphered_block[0..(to_xor.length - 1)], to_xor)
              increment_initialization_vector
            end

            k0 = encrypt_ecb(initialization_vector)[0..15]
            tag = ghash(authenticated_data, cipher_text)
            tag = Utility.xor(tag, k0)

            [cipher_text, tag]
          end

          def decrypt_gcm(cipher_text, authenticated_data, tag)
            length = cipher_text.length
            iterations = (length.to_f / @block_size).ceil
            clear_text = ''.b

            increment_initialization_vector

            k0 = encrypt_ecb(@initialization_vector)[0..15]
            computed_tag = ghash(authenticated_data, cipher_text)
            computed_tag = Utility.xor(computed_tag, k0)
            raise 'Data could not be authenticated' unless Cryptography.secure_compare(tag, computed_tag)

            increment_initialization_vector

            iterations.times do |i|
              ciphered_block = cipher(@initialization_vector)
              to_xor = cipher_text[(i * @block_size)..[(i + 1) * @block_size - 1, length - 1].min]
              clear_text << Utility.xor(ciphered_block[0..(to_xor.length - 1)], to_xor)
              increment_initialization_vector
            end

            clear_text
          end

          # Core Routines

          def cipher(clear_text)
            if clear_text.length != @block_size
              raise "Block ciphers use strict sizes (16 bytes for typical AES - received #{clear_text.length})"
            end

            state = add_round_key(clear_text, @key_schedule[0..15])

            1.upto(@rounds - 1) do |round|
              state = sub_bytes(state)
              state = shift_rows(state)
              state = mix_columns(state)
              state = add_round_key(state, @key_schedule[(round * @block_size)..((round + 1) * @block_size - 1)])
            end

            state = sub_bytes(state)
            state = shift_rows(state)
            add_round_key(state, @key_schedule[(@rounds * @block_size)..((@rounds + 1) * @block_size - 1)])
          end

          def decipher(cipher_text)
            if cipher_text.length != @block_size
              raise "Block ciphers use strict sizes (16 bytes for typical AES - received #{cipher_text.length})"
            end

            state = add_round_key(cipher_text,
                                  @key_schedule[(@rounds * @block_size)..((@rounds + 1) * @block_size - 1)])

            (@rounds - 1).downto(1) do |round|
              state = inverse_shift_rows(state)
              state = inverse_sub_bytes(state)
              state = add_round_key(state, @key_schedule[(round * @block_size)..((round + 1) * @block_size - 1)])
              state = inverse_mix_columns(state)
            end

            state = inverse_shift_rows(state)
            state = inverse_sub_bytes(state)
            add_round_key(state, @key_schedule[0..15])
          end

          def add_round_key(block, key_schedule_subset)
            Utility.xor(block, key_schedule_subset)
          end

          def shift_rows(block)
            i = 0
            result = ''.b

            16.times do
              result << block[i]
              i = (i + 5) % 16
            end

            result
          end

          def inverse_shift_rows(block)
            i = 0
            result = ''.b

            16.times do
              result << block[i]
              i = (i - 3) % 16
            end

            result
          end

          def mix_columns(block)
            ranges = [0..3, 4..7, 8..11, 12..15]
            ranges.map { |range| mix_column(block[range]) }.join
          end

          def inverse_mix_columns(block)
            ranges = [0..3, 4..7, 8..11, 12..15]
            ranges.map { |range| inverse_mix_column(block[range]) }.join
          end

          def mix_column(column)
            bytes = column.bytes
            [
              galois_multiply(bytes[0],
                              2) ^ galois_multiply(bytes[1],
                                                   3) ^ galois_multiply(bytes[2], 1) ^ galois_multiply(bytes[3], 1),
              galois_multiply(bytes[0],
                              1) ^ galois_multiply(bytes[1],
                                                   2) ^ galois_multiply(bytes[2], 3) ^ galois_multiply(bytes[3], 1),
              galois_multiply(bytes[0],
                              1) ^ galois_multiply(bytes[1],
                                                   1) ^ galois_multiply(bytes[2], 2) ^ galois_multiply(bytes[3], 3),
              galois_multiply(bytes[0],
                              3) ^ galois_multiply(bytes[1],
                                                   1) ^ galois_multiply(bytes[2], 1) ^ galois_multiply(bytes[3], 2)
            ].pack('C*')
          end

          def inverse_mix_column(column)
            bytes = column.bytes
            [
              galois_multiply(bytes[0],
                              0xe) ^ galois_multiply(bytes[1],
                                                     0xb) ^ galois_multiply(bytes[2],
                                                                            0xd) ^ galois_multiply(bytes[3], 0x9),
              galois_multiply(bytes[0],
                              0x9) ^ galois_multiply(bytes[1],
                                                     0xe) ^ galois_multiply(bytes[2],
                                                                            0xb) ^ galois_multiply(bytes[3], 0xd),
              galois_multiply(bytes[0],
                              0xd) ^ galois_multiply(bytes[1],
                                                     0x9) ^ galois_multiply(bytes[2],
                                                                            0xe) ^ galois_multiply(bytes[3], 0xb),
              galois_multiply(bytes[0],
                              0xb) ^ galois_multiply(bytes[1],
                                                     0xd) ^ galois_multiply(bytes[2],
                                                                            0x9) ^ galois_multiply(bytes[3], 0xe)
            ].pack('C*')
          end

          # in GF(2^8)
          def galois_multiply(a, b)
            p = 0
            hi_bit = 0
            8.times do
              p ^= a if b & 1 == 1
              hi_bit = a & 0x80
              a <<= 1
              a ^= 0x1b if hi_bit == 0x80
              b >>= 1
            end
            p % 256
          end

          def rot_word(word)
            ((word << 8) & 0xffffffff) | (word >> 24)
          end

          def sub_word(word)
            sub_bytes([word].pack('N*')).unpack1('N*')
          end

          def sub_bytes_core(bytes, box)
            result = ''.b
            bytes.bytes.each { |byte| result << box[byte].chr }
            result
          end

          def sub_bytes(bytes)
            sub_bytes_core(bytes, S_BOX)
          end

          def inverse_sub_bytes(bytes)
            sub_bytes_core(bytes, INVERSE_S_BOX)
          end

          def ghash(authenticated_data, cipher_text)
            to_hash = authenticated_data.b + "\x00".b * (@block_size - authenticated_data.b.length % @block_size)
            to_hash += cipher_text + "\x00".b * (@block_size - cipher_text.length % @block_size)

            tag = "\x00".b * @block_size

            Cipher.split_into_blocks(to_hash, @block_size).each do |block|
              tag = Utility.xor(tag, block)
              tag = times_auth_key(tag)
            end

            lengths = [8 * authenticated_data.length, 8 * cipher_text.length].pack('Q>2')
            tag = Utility.xor(tag, lengths)
            times_auth_key(tag)
          end

          def times_auth_key(tag)
            result = "\x00".b * @block_size

            tag.bytes.reverse.each.with_index do |byte, i|
              result = Utility.xor(result, @gcm_multiplication_table[i][byte])
            end

            result
          end

          def galois_multiply_f_2_128(x, y) # rubocop:disable Naming/VariableNumber
            result = 0
            x = Utility.byte_string_to_integer(x)

            127.downto(0) do |i|
              result ^= x * ((y >> i) & 1)  # branchless
              x = (x >> 1) ^ ((x & 1) * 0xE1000000000000000000000000000000)
            end

            Utility.integer_to_byte_string(result).rjust(@block_size, "\x00")[-16..]
          end

          def decrypt_openssl(cipher_text)
            cipher = OpenSSL::Cipher.new(@openssl_algorithm)
            cipher.decrypt
            cipher.key = @key
            cipher.iv = @initialization_vector unless @initialization_vector.nil?
            clear_text = cipher.update(cipher_text)
            clear_text + cipher.final
          end

          def encrypt_openssl(clear_text)
            cipher = OpenSSL::Cipher.new(@openssl_algorithm)
            cipher.encrypt
            cipher.key = @key
            cipher.iv = @initialization_vector unless @initialization_vector.nil?
            clear_text = cipher.update(clear_text)
            clear_text + cipher.final
          end
        end
      end
    end
  end
end
