class Dashboard::ShipmentsController < Dashboard::BaseController
  def ship
    @order = @company.orders.find_by_number(params[:orders_received_id])
    @shipment = @order.shipments.find_by_number(params[:id])

    unless @shipment.shipped?
      @shipment.ship!
    end

    redirect_to dashboard_orders_received_path(@order)
  end
end
