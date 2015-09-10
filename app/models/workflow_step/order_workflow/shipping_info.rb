class WorkflowStep::OrderWorkflow::ShippingInfo < WorkflowStep::OrderWorkflow::BaseStep

  def data
    { shipment: @order.shipments.first, order: @order }
  end

end

