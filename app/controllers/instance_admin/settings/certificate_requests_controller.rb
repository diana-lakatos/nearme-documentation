require 'nearme'

class InstanceAdmin::Settings::CertificateRequestsController < InstanceAdmin::Settings::BaseController
  def new
    @certificate_request = CertificateRequest.new
  end

  def create
    @certificate_request = CertificateRequest.new(params[:certificate_request])
    if @certificate_request.valid?
      csr = NearMe::CertificateRequestGenerator.new(@certificate_request.domain, @certificate_request.attributes)
      send_data csr.zip_file_stream, filename: zip_name
    else
      render 'new'
    end
  end

  private

  def zip_name
    '%s.%s' % [@certificate_request.domain, 'zip']
  end
end
