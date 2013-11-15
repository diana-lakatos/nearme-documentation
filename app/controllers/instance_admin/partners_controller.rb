class InstanceAdmin::PartnersController < InstanceAdmin::ResourceController

  def create
    @partner = Partner.new(params[:partner])
    @partner.instance = @instance
    create!
  end

end
