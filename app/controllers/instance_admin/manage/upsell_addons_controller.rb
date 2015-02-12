class InstanceAdmin::Manage::UpsellAddonsController < InstanceAdmin::Manage::BaseController

  def index
    @additional_charges = AdditionalChargeType.all
  end

  def new
    @additional_charge = AdditionalChargeType.new
  end

  def create
    @additional_charge = AdditionalChargeType.new(additional_charge_params)
    if @additional_charge.save
      flash[:success] = t 'flash_messages.instance_admin.manage.upsell_addons.created'
      redirect_to instance_admin_manage_upsell_addons_path
    else
      flash[:error] = @additional_charge.errors.full_messages.to_sentence
      render :new
    end
  end

  def edit
    @additional_charge = AdditionalChargeType.find(params[:id])
  end

  def update
    @additional_charge = AdditionalChargeType.find(params[:id])
    if @additional_charge.update(additional_charge_params)
      flash[:success] = t 'flash_messages.instance_admin.manage.upsell_addons.updated'
      redirect_to instance_admin_manage_upsell_addons_path
    else
      flash[:error] = @additional_charge.errors.full_messages.to_sentence
      render :edit
    end
  end

  def destroy
    @additional_charge = AdditionalChargeType.find(params[:id])
    @additional_charge.destroy
    flash[:success] = t 'flash_messages.instance_admin.manage.upsell_addons.deleted'
    redirect_to instance_admin_manage_upsell_addons_path
  end

  private
  def additional_charge_params
    params.require(:additional_charge_type).permit(secured_params.additional_charge_type)
  end
end
