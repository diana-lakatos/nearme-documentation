class CreateShippoShipmentsJob < Job
  def after_initialize(reservation)
    @reservation = reservation
  end

  def perform
    if Rails.env.production?
      @reservation.instance.set_context!
      @reservation.shipments.without_transaction.map(&:create_shippo_shipment!)
    end
  end

end
