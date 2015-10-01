require 'spec_helper'

describe Blockstack::KeychainManager  do
  before(:each) do
    @private_keychains = {
            "root" => "xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi",
            "0H" => "xprv9uHRZZhk6KAJC1avXpDAp4MDc3sQKNxDiPvvkX8Br5ngLNv1TxvUxt4cV1rGL5hj6KCesnDYUhd7oWgT11eZG7XnxHrnYeSvkzY7d2bhkJ7",
            "0H/1" => "xprv9wTYmMFdV23N2TdNG573QoEsfRrWKQgWeibmLntzniatZvR9BmLnvSxqu53Kw1UmYPxLgboyZQaXwTCg8MSY3H2EU4pWcQDnRnrVA1xe8fs",
            "0H/1/2H" => "xprv9z4pot5VBttmtdRTWfWQmoH1taj2axGVzFqSb8C9xaxKymcFzXBDptWmT7FwuEzG3ryjH4ktypQSAewRiNMjANTtpgP4mLTj34bhnZX7UiM",
            "0H/1/2H/2" => "xprvA2JDeKCSNNZky6uBCviVfJSKyQ1mDYahRjijr5idH2WwLsEd4Hsb2Tyh8RfQMuPh7f7RtyzTtdrbdqqsunu5Mm3wDvUAKRHSC34sJ7in334",
            "0H/1/2H/2/1000000000" => "xprvA41z7zogVVwxVSgdKUHDy1SKmdb533PjDz7J6N6mV6uS3ze1ai8FHa8kmHScGpWmj4WggLyQjgPie1rFSruoUihUZREPSL39UNdE3BBDu76"
        }
    @public_keychains = {
            "root" => "xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8",
            "0H" => "xpub68Gmy5EdvgibQVfPdqkBBCHxA5htiqg55crXYuXoQRKfDBFA1WEjWgP6LHhwBZeNK1VTsfTFUHCdrfp1bgwQ9xv5ski8PX9rL2dZXvgGDnw",
            "0H/1" => "xpub6ASuArnXKPbfEwhqN6e3mwBcDTgzisQN1wXN9BJcM47sSikHjJf3UFHKkNAWbWMiGj7Wf5uMash7SyYq527Hqck2AxYysAA7xmALppuCkwQ",
            "0H/1/2H" => "xpub6D4BDPcP2GT577Vvch3R8wDkScZWzQzMMUm3PWbmWvVJrZwQY4VUNgqFJPMM3No2dFDFGTsxxpG5uJh7n7epu4trkrX7x7DogT5Uv6fcLW5",
            "0H/1/2H/2" => "xpub6FHa3pjLCk84BayeJxFW2SP4XRrFd1JYnxeLeU8EqN3vDfZmbqBqaGJAyiLjTAwm6ZLRQUMv1ZACTj37sR62cfN7fe5JnJ7dh8zL4fiyLHV",
            "0H/1/2H/2/1000000000" => "xpub6H1LXWLaKsWFhvm6RVpEL9P4KfRZSW7abD2ttkWP3SSQvnyA8FSVqNTEcYFgJS2UaFcxupHiYkro49S8yGasTvXEYBVPamhGW6cFJodrTHy"
        }
    @root_private_keychain = Blockstack::KeychainManager::PrivateKeychain.new(@private_keychains["root"])
  end

  describe "PrivateKey" do
  	it "should generate root public key from root private key" do
      public_keychain = @root_private_keychain.public_keychain()
      expect(public_keychain.to_s).to eq(@public_keychains["root"])
    end

    it "should return hardened child 0 private and public keychains" do
      private_keychain = @root_private_keychain.hardened_child(0)
      expect(private_keychain.to_s).to  eq(@private_keychains["0H"])
      expect(private_keychain.public_keychain().to_s).to eq(@public_keychains["0H"])
    end

    it "should return unhardened child 0H/1 private and public keychains" do
      private_keychain =  @root_private_keychain.hardened_child(0).child(1)
      expect(private_keychain.to_s).to eq(@private_keychains["0H/1"])
      public_keychain = private_keychain.public_keychain()
      expect(public_keychain.to_s).to eq(@public_keychains["0H/1"])
      public_keychain_2 =  @root_private_keychain.hardened_child(0).public_keychain().child(1)
      expect(public_keychain.to_s).to eq(public_keychain_2.to_s)
    end

    it "should return private and public keychains for a 5 step derivation 0H/1/2H/2/1000000000" do
     private_keychain = @root_private_keychain.hardened_child(0).child(1).hardened_child(2).child(2).child(1000000000)
     expect(private_keychain.to_s).to eq(@private_keychains["0H/1/2H/2/1000000000"])
     public_keychain = private_keychain.public_keychain()
     expect(public_keychain.to_s).to eq(@public_keychains["0H/1/2H/2/1000000000"])
    end

    it "should return private key" do
      root_private_key = @root_private_keychain.private_key()
      expect(root_private_key.length).to eq(66)
    end

    it "should return bitcoin address that begins with 1" do
     address = @root_private_keychain.public_keychain().address()
     expect(address[0]).to eq('1')
    end

  end

  describe "PublicKeychainDescendant" do
    before(:each) do
      @public_keychain_string = 'xpub661MyMwAqRbcFQVrQr4Q4kPjaP4JjWaf39fBVKjPdK6oGBayE46GAmKzo5UDPQdLSM9DufZiP8eauy56XNuHicBySvZp7J5wsyQVpi2axzZ'
      @public_keychain = Blockstack::KeychainManager::PublicKeychain.new(@public_keychain_string)
      @chain_path = 'bd62885ec3f0e3838043115f4ce25eedd22cc86711803fb0c19601eeef185e39'
      @reference_public_key = '03fdd57adec3d438ea237fe46b33ee1e016eda6b585c3e27ea66686c2ea5358479'
    end

    it "should generate descendant public keychain" do
      descendant_public_keychain = @public_keychain.descendant(@chain_path)
      descendant_public_key = descendant_public_keychain.public_key()
      expect(descendant_public_key.to_s).to eq(@reference_public_key)
    end

  end

  describe "Keychain Derivation" do
    before(:each) do
      @chain_path = 'bd62885ec3f0e3838043115f4ce25eedd22cc86711803fb0c19601eeef185e39'
      @public_key_hex = '032532502314356f83068bdbd283c86398d9ffd1308192474e6d3d6156eaf3d67f'
      @private_key_hex = 'e4557e22988ab073d4c605c4548577a3c87019198e514346c26c3cff5d546f7e01'
      @reference_public_keychain = 'xpub661MyMwAqRbcEYS8w7XLSVeEsBXy79zSzH1J8vCdxAZningWLdN3zgtU6SJRqgVDtiwxFwbqpq3DhkYnpKaV7ShnnpTQTmQbf1gBWB5yEhw'
      @reference_child_0_chaincode = 'y1N\x14\x1b\xbcZ\xfe;\x88\x96\xd4\xd8@(\xe8\xc3\xd6\x9fK\x1c\x04\xa6\t\xe6%\xadz\xefcB!'

      @private_key_hex_2 = '0e1f04e0c9154cd880b4df17357516736d53d4d1a9875ae40643b3197dfb738c'
      @public_key_hex_2 = '04ed34a7f541de185fdcbf8e1a9f169b6a9146b62b34172cbfce22c0667b58e795bc28b30b931713743260390da739584eca6729af0e8011be4e5e7fb42b13c4c9'
      @reference_public_keychain_2 = 'xpub661MyMwAqRbcEYS8w7XLSVeEsBXy79zSzH1J8vCdxAZningWLdN3zgtU6TpWofxjzJQxPqLwhMi3YenYyEXtWUa55DzZZCyuZzjrrusaHDJ'

      @public_key_hex_3 = '047c7f6d1f71780ccd373a7d2a020a1aeb7d47639e86fe951f5ba23a9ca8d6f7cfb03ed7ca411b22fa5244b9998d27d9c7bf7f0603f1997d1c7b3dc5a9b342c554'
    end

    ## Not yet implemented
    # it "should derive public & private keychains from raw keys" do
    #   public_keychain = Blockstack::KeychainManager::PublicKeychain.from_public_key(@public_key_hex)
    #   private_keychain = Blockstack::KeychainManager::PrivateKeychain.from_private_key(@private_key_hex)
    #   public_keychain_2 = private_keychain.public_keychain()
    #   expect(public_keychain.to_s).to  eq(public_keychain_2.to_s)
    #   expect(public_keychain.to_s).to eq(@reference_public_keychain)
    # end
  end






end
