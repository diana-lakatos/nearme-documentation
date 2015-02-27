class InstanceAdmin::Manage::PartnersController < InstanceAdmin::Manage::BaseController

  def index
  end

  def create
    @partner = Partner.new(partner_params)
    create! { instance_admin_manage_partners_path }
  end

  def update
    @partner = Partner.find(params[:id])

    if @partner.update_attributes(partner_params)
      flash[:success] = t 'flash_messages.instance_admin.manage.partners.partner_updated'
    else
      flash[:error] = @partner.errors.full_messages.to_sentence
    end

    redirect_to edit_instance_admin_manage_partner_url(@partner.id)
  end

  private

  def partner_params
    params.require(:partner).permit(secured_params.partner)
  end
end
