require 'nearme'
require 'nearme/acm'

class InstanceAdmin::Settings::AwsCertificatesController < InstanceAdmin::Settings::BaseController
  respond_to :html
  before_action :sync_certificate_statuses, only: [:index, :show]

  def index
    respond_with :instance_admin, :settings, collection
  end

  def new
    @certificate = AwsCertificate.new

    respond_with :instance_admin, :settings, @certificate
  end

  def create
    @certificate = collection.build certificate_params

    @certificate.valid? && NearMe::ACM::RequestCertificate.new(@certificate).execute

    respond_with :instance_admin, :settings, @certificate

  rescue Aws::ACM::Errors::ValidationException
    flash[:error] = $!.message
    render :new
  end

  def show
    @view = NearMe::ACM::DescribeCertificate.new(resource)

    respond_with :instance_admin, :settings, @view
  end

  def destroy
    NearMe::ACM::DeleteCertificate.new(resource).execute
    @certificate.destroy
    respond_with :instance_admin, :settings, resource

  rescue Aws::ACM::Errors::ResourceInUseException
    flash[:error] = $!.message
    respond_with :instance_admin, :settings, :aws_certificates
  end

  protected

  def resource
    @certificate ||= collection.find params[:id]
  end

  def collection
    @certificates ||= @instance.aws_certificates
  end

  def certificate_params
    params.require(:aws_certificate).permit(secured_params.aws_certificate)
  end

  private

  def sync_certificate_statuses
    NearMe::ACM::SyncCertificatesStatuses.new(collection).execute
  end
end
