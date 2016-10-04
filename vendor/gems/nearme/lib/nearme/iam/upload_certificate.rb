class NearMe::IAM::UploadCertificate
  class NearMe::IAM::UploadError < StandardError
  end

  def initialize(certificate, params)
    @certificate = certificate
    @params = params
  end

  def execute
    response = upload_certificate

    @certificate.update_attributes arn: response.server_certificate_metadata.arn,
                                   certificate_type: 'IAM',
                                   status: 'UPLOADED'

  rescue Aws::IAM::Errors::ValidationError,
         Aws::IAM::Errors::MalformedCertificate

    raise NearMe::IAM::UploadError, $!.message
  end

  private

  def upload_certificate
    client
      .upload_server_certificate server_certificate_name: certificate_name,
                                 certificate_body: @params[:certificate_body],
                                 private_key: @params[:private_key],
                                 certificate_chain: @params[:certificate_chain]
  end

  def certificate_name
    [@certificate.name, Time.now.to_i].join('--')
  end

  def client
    Aws::IAM::Client.new
  end
end
