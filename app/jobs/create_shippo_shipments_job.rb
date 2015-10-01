class CreateShippoShipmentsJob < Job

  def after_initialize(reservation_id)
    @reservation_id = reservation_id
  end

  def perform
    @reservation = Reservation.find @reservation_id
    if @reservation.instance.shippo_enabled?
      @reservation.shipments.without_transaction.map(&:create_shippo_shipment!)
      WorkflowStepJob.new(PlatformContext.current.platform_context_detail.class.name, PlatformContext.current.platform_context_detail.id, WorkflowStep::ReservationWorkflow::ShippingDetails, @reservation.id).perform
    end
  end

end
