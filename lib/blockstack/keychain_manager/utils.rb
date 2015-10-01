module Blockstack
  module KeychainManager
    class Utils

      # Base switching
      CODE_STRINGS = {
        2 => '01',
        10 => '0123456789',
        16 => '0123456789abcdef',
        32 => 'abcdefghijklmnopqrstuvwxyz234567',
        58 => '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz',
        256 => (0..255).collect { |i| i.chr }.join
      }

      def self.extract_bin_chain_path(chain_path)
        if chain_path.length == 64
          return unhexlify(chain_path)
        elsif chain_path.length == 32
          return chain_path
        else
          raise ArgumentError.new('Invalid chain path')
        end
      end

      def self.hexlify(s)
        a = []
        s.each_byte do |b|
          a << sprintf('%02X', b)
        end
        a.join
      end

      def self.unhexlify(s)
        a = s.split
        return a.pack('H*')
      end

      def self.decode_public_key_from_compressed_hex(hex_key)
        key = hex_key.scan(/../).map { |c| "\\x%02x" % c.hex }.join
      end

      def self.decode_private_key_from_compressed_hex(hex_key)
        hex_key = hex_key.slice!(0,64).downcase
        base = 16
        code_string = CODE_STRINGS[base]

        result = 0
        while hex_key.length > 0 do
          result *= base
          result += code_string.index(hex_key[0]).nil? ? -1 : code_string.index(hex_key[0])
          hex_key = hex_key.slice(1, hex_key.length)
        end

        return result
      end
    end
  end
end
