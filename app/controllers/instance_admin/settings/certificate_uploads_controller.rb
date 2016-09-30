require 'nearme'
require 'nearme/iam'
class InstanceAdmin::Settings::CertificateUploadsController < InstanceAdmin::Settings::BaseController
  respond_to :html

  def new
    @certificate = AwsCertificate.new
  end

  def create
    @certificate = collection.build certificate_params

    NearMe::IAM::UploadCertificate.new(@certificate, params).execute

    respond_with :instance_admin, :settings, :aws_certificates
  rescue NearMe::IAM::UploadError
    flash['error'] = $!.message
    render :new
  end

  def destroy
    NearMe::IAM::DeleteCertificate.new(resource).execute
    @certificate.destroy
    respond_with :instance_admin, :settings, @certificate
  rescue
    flash[:error] = $!.message
    respond_with :instance_admin, :settings, :aws_certificates
  end

  private

  def resource
    @certificate = collection.find params[:id]
  end

  def certificate_params
    params.require(:aws_certificate).permit(secured_params.aws_certificate)
  end

  def collection
    @certificates ||= @instance.aws_certificates
  end
end
