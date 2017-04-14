# frozen_string_literal: true
class ReservationPeriodDrop < BaseDrop
  # @return [ReservationPeriodDrop]
  attr_reader :reservation_period

  # @!method description
  #   @return [String] description for the reservation period
  # @!method hours
  #   @return [Float] the number of hours reserved on this date; if no hourly time specified,
  #     it is assumed that the reservation is for all open hours of that booking.
  delegate :description, :hours, :start_minute, :end_minute, :date, to: :source

end
