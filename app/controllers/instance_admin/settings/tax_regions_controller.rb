class InstanceAdmin::Settings::TaxRegionsController < InstanceAdmin::Manage::BaseController
  before_filter :set_breadcrumps, only: [:index, :new, :edit]
  before_filter :find_instance

  def index
    @tax_regions = TaxRegion.order(:created_at)
  end

  def new
    @tax_region = TaxRegion.new
    @tax_region.tax_rates.build(default: true)
  end

  def create
    @tax_region = TaxRegion.new(tax_region_params)
    if @tax_region.save
      flash[:success] = t 'flash_messages.instance_admin.manage.tax_region.created'
      redirect_to edit_instance_admin_settings_tax_region_path(@tax_region)
    else
      flash.now[:error] = @tax_region.errors.full_messages.to_sentence
      render :new
    end
  end

  def edit
    @tax_region = TaxRegion.find(params[:id])
    @tax_region.tax_rates.first_or_initialize
  end

  def update_settings
    @instance.update_attributes(params[:instance].permit(:tax_included_in_price))
    redirect_to instance_admin_settings_tax_regions_path
  end

  def update
    @tax_region = TaxRegion.find(params[:id])
    if @tax_region.update(tax_region_params)
      flash[:success] = t 'flash_messages.instance_admin.manage.tax_region.updated'
      redirect_to instance_admin_settings_tax_regions_path
    else
      flash.now[:error] = @tax_region.errors.full_messages.to_sentence
      render :edit
    end
  end

  def destroy
    @tax_region = TaxRegion.find(params[:id])
    @tax_region.destroy
    flash[:success] = t 'flash_messages.instance_admin.manage.tax_region.deleted'
    redirect_to instance_admin_settings_tax_regions_path
  end

  def set_breadcrumps
    @breadcrumbs_title = 'Tax Settings'
  end

  private

  def find_instance
    @instance = current_instance
  end

  def tax_region_params
    params.require(:tax_region).permit(secured_params.tax_region)
  end
end
