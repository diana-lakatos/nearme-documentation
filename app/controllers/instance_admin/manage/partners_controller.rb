class InstanceAdmin::Manage::PartnersController < InstanceAdmin::Manage::BaseController
  def index
  end

  def create
    @partner = Partner.new(partner_params)

    if @partner.save
      create_theme! && return if params[:add_theme].present?
      redirect_to instance_admin_manage_partners_path
    else
      render action: :new
    end
  end

  def update
    @partner = Partner.find(params[:id])

    if @partner.update_attributes(partner_params)
      create_theme! && return if params[:add_theme].present?
      flash[:success] = t 'flash_messages.instance_admin.manage.partners.partner_updated'
    else
      flash[:error] = @partner.errors.full_messages.to_sentence
    end

    redirect_to edit_instance_admin_manage_partner_url(@partner.id)
  end

  private

  def create_theme!
    @partner.build_theme_from_instance.save!
    redirect_to edit_instance_admin_manage_partner_path(@partner)
  end

  def partner_params
    params.require(:partner).permit(secured_params.partner)
  end
end
