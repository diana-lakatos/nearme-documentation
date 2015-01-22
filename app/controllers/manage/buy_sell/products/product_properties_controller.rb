class Manage::BuySell::Products::ProductPropertiesController < Manage::BuySell::BaseController

  before_filter :find_product
  before_filter :find_product_property, only: [:edit, :update, :destroy]

  def index
    @product_properties = @product.product_properties.paginate(page: params[:page], per_page: 20)
  end

  def new
    @product_property = @product.product_properties.build company: @company
  end

  def create
    @product_property = @product.product_properties.new(property_params)
    if @product_property.save
      redirect_to location_after_save, notice: t('flash_messages.manage.product_property.created')
    else
      flash[:error] = t('flash_messages.manage.product_property.error_create')
      render :new
    end
  end

  def edit
  end

  def update
    if @product_property.update_attributes(property_params)
      redirect_to location_after_save, notice: t('flash_messages.manage.product_property.updated')
    else
      flash[:error] = t('flash_messages.manage.product_property.error_update')
      render :edit
    end
  end

  def destroy
    @product_property.destroy
    flash[:notice] = t('flash_messages.manage.product_property.deleted')
    redirect_to location_after_save
   end

  private

  def location_after_save
    manage_buy_sell_product_product_properties_path(@product)
  end

  def find_product_property
    @product_property = @product.product_properties.find(params[:id])
  end

  def property_params
    params.require(:product_property).permit(secured_params.spree_product_property)
  end
end
