require 'openssl'
require 'zip'

module NearMe
  class CertificateRequestGenerator
    FORMAT = "%s.%s"
    attr_accessor :domain, :options
    def initialize(domain, options)
      self.domain = domain
      self.options = options
    end

    def key
      @key ||= OpenSSL::PKey::RSA.generate(2048)
    end

    def public_key
      @public_key ||= key.public_key
    end

    def private_key
      @private_key ||= key.to_s
    end

    def csr
      @csr ||= begin
                 request = OpenSSL::X509::Request.new
                 request.version = 0 
                 request.subject = OpenSSL::X509::Name.new([
                   ['C',             self.options[:country],      OpenSSL::ASN1::PRINTABLESTRING],
                   ['ST',            self.options[:state],        OpenSSL::ASN1::PRINTABLESTRING],
                   ['L',             self.options[:city],         OpenSSL::ASN1::PRINTABLESTRING],
                   ['O',             self.options[:organization], OpenSSL::ASN1::UTF8STRING],
                   ['OU',            self.options[:department],   OpenSSL::ASN1::UTF8STRING],
                   ['CN',            self.options[:common_name],  OpenSSL::ASN1::UTF8STRING],
                   ['emailAddress',  self.options[:email],        OpenSSL::ASN1::UTF8STRING]

                 ])
                 request.public_key = public_key
                 request.sign(key, OpenSSL::Digest::SHA1.new)
                 request.to_s
               end
    end

    def zip_file_stream
      @_file ||= begin
                   stringio = Zip::OutputStream.write_buffer do |zip|
                     zip.put_next_entry(FORMAT % [self.domain, 'key'])
                     zip.write private_key

                     zip.put_next_entry(FORMAT % [self.domain, 'pub'])
                     zip.write public_key.to_s

                     zip.put_next_entry(FORMAT % [self.domain, 'csr'])
                     zip.write csr
                   end

                   stringio.rewind
                   stringio.sysread
                 end
    end
  end
end
