# Custom Encryptor for attr_encrypted gem to avoid errors with decryption data from production in staging/development mode
# The secret_key is different in each environment so we would get CipherError when trying to decrypt data with wrong key.
class AttrEncryptedEncryptor

  class << self

    def encrypt(options, &block)
      Encryptor.encrypt(options, &block)
    end

    def decrypt(options, &block)
      begin
        Encryptor.decrypt(options, &block)
      rescue OpenSSL::Cipher::CipherError
        if options[:marshal]
          options[:marshaler].send(options[:dump_method], nil)
        else
          ''
        end
      end
    end

  end
end
