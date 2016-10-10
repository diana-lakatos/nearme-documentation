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
    { reservation: @reservation, user: lister, host: enquirer, listing: @reservation.transactable, inbound_shipping: @reservation.shipments.inbound.first, outbound_shipping: @reservation.shipments.outbound.first }
  end
end
