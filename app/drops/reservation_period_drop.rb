class ReservationPeriodDrop < BaseDrop

  # @return [ReservationPeriodDrop]
  attr_reader :reservation_period

  # @!method description
  #   @return (see ReservationPeriod#description)
  # @!method hours
  #   @return (see ReservationPeriod#hours)
  delegate :description, :hours, to: :reservation_period

  def initialize(reservation_period)
    @reservation_period = reservation_period
  end

end
