module Blockstack
  module KeychainManager
    class PrivateKeychain
      attr_accessor :hdkeychain

      def initialize(private_keychain=nil)
        if private_keychain
          if private_keychain.is_a?(MoneyTree::Node)
            self.hdkeychain = private_keychain
          elsif private_keychain.is_a? String
            self.hdkeychain = MoneyTree::Node.from_bip32(private_keychain)
          else
            raise ArgumentError('Private keychain must be a String or MoneyTree::Node.')
          end
        else
          self.hdkeychain = MoneyTree::Master.new
        end
      end
      def to_s
        self.hdkeychain.to_bip32(:private)
      end

      def hardened_child(index)
        # p indicates prime
        # see https://github.com/GemHQ/money-tree#values-of-i-and-i-prime
        child_keychain = self.hdkeychain.node_for_path("#{index}p")
        return PrivateKeychain.new(child_keychain)
      end

      def child(index)
        child_keychain = self.hdkeychain.node_for_path("#{index}")
        return PrivateKeychain.new(child_keychain)
      end

      def public_keychain
        public_keychain = self.hdkeychain.clone()
        public_keychain.strip_private_info!
        return PublicKeychain.new(public_keychain)
      end

      def private_key(compressed=true)
        if compressed
          return self.hdkeychain.private_key.to_hex + '01'
        else
          return self.hdkeychain.private_key.to_hex
        end
      end

      def self.from_private_key(private_key, chain_path="\x00"*32, depth=0,
                         fingerprint="\x00"*4, child_index=0)

        raise NotImplementedError.new if chain_path != "\x00"*32 || depth !=0 || \
          fingerprint != "\x00"*4 || child_index != 0

        private_key_raw = Utils.decode_private_key_from_compressed_hex(private_key)
        private_key = MoneyTree::PrivateKey.new(key: private_key_raw)
        node = MoneyTree::Master.new({:private_key => private_key, :chain_code => 0})

        public_keychain_string = node.to_bip32
        p node.to_bip32
        return PrivateKeychain.new(public_keychain_string)
      end

    end
  end
end
