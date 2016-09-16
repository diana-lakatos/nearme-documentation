class NearMe::ACM::SyncCertificatesStatuses
  def initialize(certificates)
    @certificates = certificates.where("arn like '%acm%'")
  end

  def execute
    @certificates.each do |certificate|
      client.describe_certificate(certificate_arn: certificate.arn).tap do |resp|
        certificate.update_attributes status: resp.certificate.status
      end
    end
  end

  private

  def client
    Aws::ACM::Client.new
  end
end
