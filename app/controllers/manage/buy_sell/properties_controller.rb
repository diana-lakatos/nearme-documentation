class Manage::BuySell::PropertiesController < Manage::BuySell::BaseController
  before_filter :find_property, only: [:edit, :update, :destroy]

  def index
    @properties = @company.properties.paginate(page: params[:page], per_page: 20)
  end

  def new
    @property = @company.properties.build
  end

  def create
    @property = @company.properties.new(property_params)
    if @property.save
      redirect_to location_after_save, notice: t('flash_messages.manage.property.created')
    else
      flash[:error] = t('flash_messages.manage.property.error_create')
      render :new
    end
  end

  def edit
  end

  def update
    if @property.update_attributes(property_params)
      redirect_to location_after_save, notice: t('flash_messages.manage.property.updated')
    else
      flash[:error] = t('flash_messages.manage.property.error_update')
      render :edit
    end
  end

  def destroy
    @property.destroy
    flash[:notice] = t('flash_messages.manage.property.deleted')
    redirect_to location_after_save
   end

  private

  def location_after_save
    manage_buy_sell_properties_path
  end

  def find_property
    @property = @company.properties.find(params[:id])
  end

  def property_params
    params.require(:property).permit(secured_params.spree_property)
  end
end
