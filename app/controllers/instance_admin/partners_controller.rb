class InstanceAdmin::PartnersController < InstanceAdmin::ResourceController

  def create
    @partner = Partner.new(params[:partner])
    @partner.instance = platform_context.instance
    create!
  end

end
