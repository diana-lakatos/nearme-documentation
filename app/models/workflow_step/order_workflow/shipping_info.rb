class WorkflowStep::OrderWorkflow::ShippingInfo < WorkflowStep::OrderWorkflow::BaseStep


  # shipment:
  #   Spree::Shipment object
  # order:
  #   Spree::Order object
  def data
    { shipment: @order.shipments.first, order: @order }
  end

end

