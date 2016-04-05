class ReservationRequestDrop < BaseDrop
  attr_reader :reservation_request

  # with_delivery?
  #   returns true if reservation is with delivery
  # action_hourly_booking?
  #   returns true if reservation is per hour

  delegate :with_delivery?, :action_hourly_booking?,
    :has_service_fee?, to: :reservation_request

  def initialize(reservation_request)
    @reservation_request = reservation_request
  end

end
