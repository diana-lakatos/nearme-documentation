class WorkflowStep::OfferWorkflow::ShippingDetails < WorkflowStep::OfferWorkflow::BaseStep
  # inbound_shipping_details:
  #   Shipping details for the return shipment
  # outbound_shipping_details:
  #   Shipping details for the rented item
  def data
    super.merge(inbound_shipping: @offer.shipments.inbound.first, outbound_shipping: @offer.shipments.outbound.first)
  end
end
