# frozen_string_literal: true
class AvailabilityRule::HourlyListingStatus
  def initialize(action, date, step=15)
    @action = action
    @transactable = action.transactable
    @date = date
    @schedule = {}
    if @action.availability.open_on?(date: @date)
      @rules = @action.availability.rules_for_day(@date.wday)
      @rules.each do |rule|
        (rule.day_open_minute..rule.day_close_minute).step(step) do |minute|
          @schedule[minute] = @transactable.quantity_for(date)
        end
      end
    end

    build_time_quantities
  end

  def as_json
    @schedule
  end

  def day_availability
    @schedule.map {|s| OpenStruct.new(minute: s.first, quantity: s.last) }
  end

  def build_time_quantities
    periods.each do |period|
      if period.start_minute.present?
        range = (period.start_minute.to_i..period.end_minute.to_i)
        @schedule.keys.each { |k| @schedule[k] -= period.quantity_booked.to_i if range.include?(k.to_i) }
      else
        @schedule.keys.each { |k| @schedule[k] -= period.quantity_booked.to_i }
      end
    end
  end

  def periods
    @transactable
      .orders.reservations.confirmed.joins(:periods)
      .where("reservation_periods.date = ? OR (EXTRACT(DOW FROM reservation_periods.date) = ?
        AND reservation_periods.recurring_frequency_unit = 'day' AND reservation_periods.recurring_frequency = 7)", @date, @date.wday)
      .select('orders.quantity as quantity_booked, reservation_periods.start_minute, reservation_periods.end_minute')
  end
end
