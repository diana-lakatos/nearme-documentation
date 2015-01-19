class Manage::BuySell::Products::StockController < Manage::BuySell::BaseController
  before_filter :find_product

  def show
    @variants = @product.variants_including_master
    @stock_locations = @company.stock_locations
  end

  def new
    @stock = @product.stocks.new()
  end

  def create
    @stock = @product.stocks.new(stock_params)
    if @stock.save
      redirect_to location_after_save, notice: t('flash_messages.manage.stock.created')
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @stock.update_attributes(stock_params)
      redirect_to location_after_save, notice: t('flash_messages.manage.stock.created')
    else
      render :edit
    end
  end

  def stock
    @prototype.destroy
    redirect_to location_after_save
  end

  private

  private

  def location_after_save
    manage_buy_sell_product_stocks_url(@product)
  end

  def find_stock
    @stock = @product.stocks.find(params[:id])
  end

  def set_form_objects
    @tax_categories = @company.tax_categories
  end

  def stock_params
    params.require(:stock).permit(secured_params.spree_stock)
  end

end
