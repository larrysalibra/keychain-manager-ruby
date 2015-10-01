module Blockstack
  module KeychainManager
    class PublicKeychain
      attr_accessor :hdkeychain

      def initialize(public_keychain)
        if public_keychain.is_a? MoneyTree::Node
          self.hdkeychain = public_keychain
        elsif public_keychain.is_a? String
          self.hdkeychain = MoneyTree::Master.from_bip32(public_keychain)
        else
          raise ArgumentError('Public keychain must be a String or MoneyTree::Node.')
        end
      end

      def to_s
        return self.hdkeychain.to_bip32(:public)
      end

      def child(index)
        child_keychain = self.hdkeychain.node_for_path("#{index}")
        child_keychain.strip_private_info!
        return PublicKeychain.new(child_keychain)
      end

      def descendant(chain_path)
        public_child = self.hdkeychain
        chain_step_bytes = 4
        max_bits_per_step = 2**31

        chain_steps = []
        for i in (0..chain_path.length - 1).step(chain_step_bytes * 2)
          chain_steps.push(chain_path.slice(i, chain_step_bytes * 2).to_i(16) % max_bits_per_step)
        end

        for step in chain_steps
          public_child = public_child.node_for_path("#{step}")
        end

        public_child.strip_private_info!
        return PublicKeychain.new(public_child)
      end

      def public_key(compressed=true)
        if compressed
          return self.hdkeychain.public_key.compressed.to_hex
        else
          return self.hdkeychain.public_key.uncompressed.to_hex
        end
      end

      def address
        return self.hdkeychain.public_key.to_address
      end


      def self.from_public_key(public_key, chain_path="\x00"*32, depth=0,
        fingerprint="\x00"*4, child_index=0)
        raise NotImplementedError.new
      end

    end
  end
end
