class NearMe::ACM::DescribeCertificate
  extend Forwardable

  def_delegators :details, :certificate_arn,
                 :domain_name, :subject_alternative_names,
                 :status, :revoked_at, :not_before, :not_after,
                 :in_use_by, :created_at, :issued_at,
                 :domain_validation_options

  def initialize(certificate)
    @certificate = certificate
  end

  def validation_emails
    details.domain_validation_options[0].validation_emails
  end

  def details
    @details ||= response.certificate
  end

  private

  def response
    @response ||= client.describe_certificate(certificate_arn: @certificate.arn)
  end

  def client
    Aws::ACM::Client.new
  end
end
