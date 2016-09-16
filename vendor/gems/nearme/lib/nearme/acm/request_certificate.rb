module NearMe
  module ACM
    class RequestCertificate
      def initialize(certificate)
        @certificate = certificate
      end

      def execute
        request_certificate.tap do |response|
          @certificate.update_attributes arn: response.certificate_arn,
                                         status: 'PENDING_VALIDATION'
        end
      end

      private

      def request_certificate
        client.request_certificate domain_name: @certificate.name,
                                   subject_alternative_names: @certificate.domain_list
      end

      def client
        Aws::ACM::Client.new
      end
    end
  end
end
