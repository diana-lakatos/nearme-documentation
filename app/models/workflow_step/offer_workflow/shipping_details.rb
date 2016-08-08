class WorkflowStep::OfferWorkflow::ShippingDetails < WorkflowStep::OfferWorkflow::BaseStep

  # offer:
  #   Offer object
  # user:
  #   listing User object
  # host:
  #   enquiring User object
  # listing:
  #   Transactable object
  # inbound_shipping_details:
  #   Shipping details for the return shipment
  # outbound_shipping_details:
  #   Shipping details for the rented item
  def data
    { offer: @offer, user: lister, host: enquirer, listing: @offer.transactable, inbound_shipping: @offer.shipments.inbound.first, outbound_shipping: @offer.shipments.outbound.first }
  end

end
