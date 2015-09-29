class CreateShippoShipmentsJob < Job
  def after_initialize(reservation)
    @reservation = reservation
  end

  def perform
    if Rails.env.production? || Rails.env.staging?
      @reservation.instance.set_context!
      @reservation.shipments.without_transaction.map(&:create_shippo_shipment!)
      WorkflowStepJob.perform(WorkflowStep::ReservationWorkflow::ShippingDetails, @reservation.id)
    end
  end

end
