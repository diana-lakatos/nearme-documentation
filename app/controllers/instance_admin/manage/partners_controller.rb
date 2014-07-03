class InstanceAdmin::Manage::PartnersController < InstanceAdmin::Manage::BaseController

  def index
  end

  def create
    @partner = Partner.new(partner_params)
    create! { instance_admin_manage_partners_path }
  end

  private

  def partner_params
    params.require(:partner).permit(secured_params.partner)
  end
end
