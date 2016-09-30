require 'nearme'

class InstanceAdmin::Settings::AwsCertificateConfirmationsController < InstanceAdmin::Settings::BaseController
  respond_to :html

  def create
    NearMe::ACM::ResendConfirmation.new(resource).execute

    flash[:notice] = 'Success. We sent new validation email for this certificate.'
    redirect_to instance_admin_settings_aws_certificate_url(resource)
  end

  protected

  def resource
    AwsCertificate.find params[:id]
  end
end
