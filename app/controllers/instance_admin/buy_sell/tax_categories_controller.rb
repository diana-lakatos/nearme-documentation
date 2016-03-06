class InstanceAdmin::BuySell::TaxCategoriesController < InstanceAdmin::BuySell::BaseController

  def index
    @tax_categories = tax_category_scope.all
  end

  def new
    @tax_category = tax_category_scope.new
  end

  def create
    @tax_category = tax_category_scope.new(tax_category_params)
    if @tax_category.save
      flash[:success] = t('flash_messages.buy_sell.tax_category_added')
      redirect_to instance_admin_buy_sell_tax_categories_path
    else
      render :new
    end
  end

  def edit
    @tax_category = tax_category_scope.find(params[:id])
  end

  def update
    @tax_category = tax_category_scope.find(params[:id])
    if @tax_category.update_attributes(tax_category_params)
      flash[:success] = t('flash_messages.buy_sell.tax_category_updated')
      redirect_to instance_admin_buy_sell_tax_categories_path
    else
      render 'edit'
    end
  end

  def destroy
    @tax_category = tax_category_scope.find(params[:id])
    @tax_category.destroy
    flash[:success] = t('flash_messages.buy_sell.tax_category_deleted')
    if request.xhr?
      render json: { success: true }
    else
      redirect_to instance_admin_buy_sell_tax_categories_path
    end
  end

  private

  def tax_category_scope
    Spree::TaxCategory
  end

  def tax_category_params
    params.require(:tax_category).permit(secured_params.tax_category)
  end
end
