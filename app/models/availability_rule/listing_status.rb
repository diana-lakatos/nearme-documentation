# encoding: utf-8
#
# Determines and encodes availability status into the future
class AvailabilityRule::ListingStatus
  attr_reader :start_date, :end_date

  def initialize(action, start_date, end_date)
    @action = action
    @listing = action.transactable
    @start_date = start_date
    @end_date = end_date
  end

  def availability_for(date)
    return if date < @start_date || date > @end_date
    return unless @action.open_on?(date)

    if @action.hour_booking?
      @listing.quantity
    else
      q = @listing.quantity - booked_on(date)
      q = 0 if q < 0
      q
    end
  end

  def as_json
    hash = {}
    current = start_date.beginning_of_month
    while current < @end_date
      arr = hash[current.strftime("%Y-%-m")] = []
      current_day = current
      while current_day <= current.end_of_month
        arr << availability_for(current_day)
        current_day = current_day.advance(:days => 1)
      end

      current = current.advance(:months => 1)
    end

    hash
  end

  private

  def booked_by_date
    @booked_by_date ||= begin
      @listing.orders.reservations.confirmed.
        joins(:periods).
        where(:reservation_periods => { :date => @start_date..@end_date }).
        group('reservation_periods.date').
        sum(:quantity)
    end
  end

  def booked_on(date)
    booked_by_date[date.to_date] || 0
  end
end
