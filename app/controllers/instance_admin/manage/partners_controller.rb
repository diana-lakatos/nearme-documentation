class InstanceAdmin::Manage::PartnersController < InstanceAdmin::Manage::BaseController

  def index
  end

  def create
    @partner = Partner.new(params[:partner])
    @partner.instance = platform_context.instance
    create!
  end
end
