class Manage::BuySell::StockLocationsController < Manage::BuySell::BaseController
  before_filter :find_stock_location, only: [:edit, :update, :destroy]

  def index
    @stock_locations = @company.stock_locations.paginate(page: params[:page], per_page: 20)
  end

  def new
    @stock_location = @company.stock_locations.build
  end

  def create
    @stock_location = @company.stock_locations.new(stock_location_params)
    if @stock_location.save
      redirect_to location_after_save, notice: t('flash_messages.manage.stock_location.created')
    else
      flash[:error] = t('flash_messages.manage.stock_location.error_create')
      render :new
    end
  end

  def edit
  end

  def update
    if @stock_location.update_attributes(stock_location_params)
      redirect_to location_after_save, notice: t('flash_messages.manage.stock_location.updated')
    else
      flash[:error] = t('flash_messages.manage.stock_location.error_update')
      render :edit
    end
  end

  def destroy
    @stock_location.destroy
    flash[:notice] = t('flash_messages.manage.stock_location.deleted')
    redirect_to location_after_save
   end

  private

  def location_after_save
    manage_buy_sell_stock_locations_path
  end

  def find_stock_location
    @stock_location = @company.stock_locations.find(params[:id])
  end

  def stock_location_params
    params.require(:stock_location).permit(secured_params.spree_stock_location)
  end
end
