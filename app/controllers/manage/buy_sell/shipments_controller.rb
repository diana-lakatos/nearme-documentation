class Manage::BuySell::ShipmentsController < Manage::BuySell::BaseController
  def ship
    @order = @company.orders.find_by_number(params[:order_id])
    @shipment = @order.shipments.find_by_number(params[:id])
    unless @shipment.shipped?
      @shipment.ship!
    end
    redirect_to :back
  end
end
