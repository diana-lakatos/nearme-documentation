class InstanceAdmin::BuySell::ShippingCategoriesController < InstanceAdmin::BuySell::BaseController

  def index
    @shipping_categories = shipping_category_scope.all
  end

  def new
    @shipping_category = shipping_category_scope.new
  end

  def create
    @shipping_category = shipping_category_scope.new(shipping_category_params)
    if @shipping_category.save
      flash[:success] = t('flash_messages.buy_sell.shipping_category_added')
      redirect_to instance_admin_buy_sell_shipping_categories_path
    else
      flash.now[:error] = @shipping_category.errors.full_messages.join(', ')
      render :new
    end
  end

  def edit
    @shipping_category = shipping_category_scope.find(params[:id])
  end

  def update
    @shipping_category = shipping_category_scope.find(params[:id])
    if @shipping_category.update_attributes(shipping_category_params)
      flash[:success] = t('flash_messages.buy_sell.shipping_category_updated')
      redirect_to instance_admin_buy_sell_shipping_categories_path
    else
      render 'edit'
    end
  end

  def destroy
    @shipping_category = shipping_category_scope.find(params[:id])
    @shipping_category.destroy
    flash[:success] = t('flash_messages.buy_sell.shipping_category_deleted')
    if request.xhr?
      render json: { success: true }
    else
      redirect_to instance_admin_buy_sell_shipping_categories_path
    end
  end

  private

  def shipping_category_scope
    Spree::ShippingCategory
  end

  def shipping_category_params
    params.require(:shipping_category).permit(secured_params.shipping_category)
  end

end
