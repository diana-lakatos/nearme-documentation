class InstanceAdmin::Manage::PartnersController < InstanceAdmin::Manage::BaseController

  def create
    @partner = Partner.new(params[:partner])
    @partner.instance = platform_context.instance
    create!
  end
end
