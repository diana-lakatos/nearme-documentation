class Dashboard::Company::ShipmentsController < Dashboard::Company::BaseController
  def ship
    @order = @company.orders.find_by_number(params[:orders_received_id])
    @shipment = @order.shipments.find_by_number(params[:id])

    unless @shipment.shipped?
      @shipment.ship!
      @order.touch(:archived_at)
    end

    redirect_to dashboard_company_orders_received_path(@order)
  end
end
