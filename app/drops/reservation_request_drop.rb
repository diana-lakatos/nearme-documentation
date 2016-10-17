class ReservationRequestDrop < BaseDrop
  # @todo Class no longer present, should probably be removed
  attr_reader :reservation_request

  delegate :with_delivery?, :action_hourly_booking?,
           :has_service_fee?, to: :reservation_request

  def initialize(reservation_request)
    @reservation_request = reservation_request
  end
end
