class InstanceAdmin::Manage::AdditionalChargeTypesController < InstanceAdmin::Manage::BaseController
  before_filter :set_breadcrumps, only: [:index, :new, :edit]

  def index
    @additional_charge_types = AdditionalChargeType.admin_charges.order(:created_at)
  end

  def new
    @additional_charge_type = AdditionalChargeType.new
  end

  def create
    @additional_charge_type = AdditionalChargeType.new(additional_charge_params)
    if @additional_charge_type.save
      flash[:success] = t 'flash_messages.instance_admin.manage.upsell_addons.created'
      redirect_to instance_admin_manage_additional_charge_types_path
    else
      flash.now[:error] = @additional_charge_type.errors.full_messages.to_sentence
      render :new
    end
  end

  def edit
    @additional_charge_type = AdditionalChargeType.admin_charges.find(params[:id])
  end

  def update
    @additional_charge_type = AdditionalChargeType.admin_charges.find(params[:id])
    if @additional_charge_type.update(additional_charge_params)
      flash[:success] = t 'flash_messages.instance_admin.manage.upsell_addons.updated'
      redirect_to instance_admin_manage_additional_charge_types_path
    else
      flash.now[:error] = @additional_charge_type.errors.full_messages.to_sentence
      render :edit
    end
  end

  def destroy
    @additional_charge_type = AdditionalChargeType.admin_charges.find(params[:id])
    @additional_charge_type.destroy
    flash[:success] = t 'flash_messages.instance_admin.manage.upsell_addons.deleted'
    redirect_to instance_admin_manage_additional_charge_types_path
  end

  def set_breadcrumps
    @breadcrumbs_title = 'Upsell & Add-ons'
  end

  private

  def additional_charge_params
    params.require(:additional_charge_type).permit(secured_params.additional_charge_type)
  end
end
