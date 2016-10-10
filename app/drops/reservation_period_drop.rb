class ReservationPeriodDrop < BaseDrop
  attr_reader :reservation_period

  delegate :description, :hours, to: :reservation_period

  def initialize(reservation_period)
    @reservation_period = reservation_period
  end
end
