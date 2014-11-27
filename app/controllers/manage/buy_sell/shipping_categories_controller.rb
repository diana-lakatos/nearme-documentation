class Manage::BuySell::ShippingCategoriesController < Manage::BuySell::BaseController
  before_filter :find_shipping_category, only: [:edit, :update, :destroy]

  def index
    @shipping_categories = @company.shipping_categories.paginate(page: params[:page], per_page: 20)
  end

  def new
    @shipping_category = @company.shipping_categories.build
  end

  def create
    @shipping_category = @company.shipping_categories.new(shipping_category_params)
    if @shipping_category.save
      redirect_to location_after_save, notice: t('flash_messages.manage.shipping_category.created')
    else
      flash[:error] = t('flash_messages.manage.shipping_category.error_create')
      render :new
    end
  end

  def edit
  end

  def update
    if @shipping_category.update_attributes(shipping_category_params)
      redirect_to location_after_save, notice: t('flash_messages.manage.shipping_category.updated')
    else
      flash[:error] = t('flash_messages.manage.shipping_category.error_update')
      render :edit
    end
  end

  def destroy
    @shipping_category.destroy
    flash[:notice] = t('flash_messages.manage.shipping_category.deleted')
    redirect_to location_after_save
   end

  private

  def location_after_save
    manage_buy_sell_shipping_categories_path
  end

  def find_shipping_category
    @shipping_category = @company.shipping_categories.find(params[:id])
  end

  def shipping_category_params
    params.require(:shipping_category).permit(secured_params.spree_shipping_category)
  end
end
