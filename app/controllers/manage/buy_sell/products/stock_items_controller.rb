class Manage::BuySell::Products::StockItemsController < Manage::BuySell::BaseController
  before_filter :find_product
  before_filter :determine_backorderable, only: :update

  def update
    stock_item.save
    respond_to do |format|
      format.js { head :ok }
    end
  end

  def create
    variant = @product.variants.find(params[:variant_id])
    stock_location = @company.stock_locations.find(params[:stock_location_id])
    stock_movement = stock_location.stock_movements.build(stock_movement_params)
    stock_movement.stock_item = stock_location.set_up_stock_item(variant)

    if stock_movement.save
      flash[:success] = t('flash_messages.manage.stock_movement.created')
    else
      flash[:error] = t('flash_messages.manage.stock_movement.create_error')
    end

    redirect_to :back
  end

  def destroy
    stock_item.destroy

    respond_with(@stock_item) do |format|
      format.html { redirect_to :back }
      format.js
    end
  end

  private
    def stock_movement_params
      params.require(:stock_movement).permit(secured_params.spree_stock_movement)
    end

    def stock_item
      @stock_item ||= @product.stock_items.find(params[:id])
    end

    def determine_backorderable
      stock_item.backorderable = params[:stock_item].present? && params[:stock_item][:backorderable].present?
    end
end
