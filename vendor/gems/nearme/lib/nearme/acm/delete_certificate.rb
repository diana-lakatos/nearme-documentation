class NearMe::ACM::DeleteCertificate
  def initialize(certificate)
    @certificate = certificate
  end

  def execute
    delete_certificate
  end

  private

  def delete_certificate
    client.delete_certificate certificate_arn: @certificate.arn
  end

  def client
    Aws::ACM::Client.new
  end
end
