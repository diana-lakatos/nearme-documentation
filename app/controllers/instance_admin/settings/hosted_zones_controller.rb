class InstanceAdmin::Settings::HostedZonesController < InstanceAdmin::Settings::BaseController
  respond_to :html

  def create
    SetupHostedZoneJob.perform(domain.id)
    redirect_to instance_admin_settings_domain_path(domain)
  end

  private

  def domain
    Domain.find(params[:domain_id])
  end

  def permitting_controller_class
    'AdministratorRestrictedAccess'
  end
end
