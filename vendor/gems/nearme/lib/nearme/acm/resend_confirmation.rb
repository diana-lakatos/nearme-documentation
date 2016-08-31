class NearMe::ACM::ResendConfirmation
  def initialize(certificate)
    @certificate = certificate
  end

  def execute
    details.domain_validation_options.map do |validation|
      {
        certificate_arn: @certificate.arn,
        domain: validation.domain_name,
        validation_domain: validation.validation_domain
      }
    end.each do |params|
      client.resend_validation_email params
    end
  end

  private

  def details
    NearMe::ACM::DescribeCertificate.new(@certificate)
  end

  def client
    Aws::ACM::Client.new
  end
end
