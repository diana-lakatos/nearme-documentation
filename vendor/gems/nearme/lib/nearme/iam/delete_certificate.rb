# AWS Identity and Access Management
class NearMe::IAM::DeleteCertificate
  def initialize(certificate)
    @certificate = certificate
  end

  def execute
    delete_certificate
  end

  private

  def delete_certificate
    metadata = find_certificate_metadata

    client.delete_server_certificate server_certificate_name: metadata.server_certificate_name
  end

  def find_certificate_metadata
    client.list_server_certificates.server_certificate_metadata_list.find { |x| x.arn == @certificate.arn }
  end

  def client
    Aws::IAM::Client.new
  end
end
