class InstanceAdmin::Manage::PartnersController < InstanceAdmin::Manage::BaseController

  def index
  end

  def create
    @partner = Partner.new(params[:partner])
    create! { instance_admin_manage_partners_path }
  end
end
