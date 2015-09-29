class WorkflowStep::ReservationWorkflow::ShippingDetails < WorkflowStep::ReservationWorkflow::BaseStep

  # reservation:
  #   Reservation object
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
    { reservation: @reservation, user: lister, host: enquirer, listing: @reservation.listing, inbound_shipping_details: @reservation.shipments.inbound.first.try(:label_url), outbound_shipping_details: @reservation.shipments.outbound.first.try(:tracking_url_provider) }
  end

end
