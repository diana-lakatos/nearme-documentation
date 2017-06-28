# frozen_string_literal: true
class AvailabilityRule::WeekAvailability
  def initialize(action, step)
    @action = action
    @transactable = action.transactable
    @schedule = @transactable.availability.days_with_minutes_by_step(step)

    build_time_quantities
  end

  def as_json
    @schedule.map {|day, availability| OpenStruct.new(day_name: I18n.t('date.day_names')[day.to_i], day: day, availability: availability.map {|m| OpenStruct.new(minute: m.first.first, quantity: 1) }) }
  end

  def build_time_quantities
    orders = @transactable.orders.reservations.confirmed.joins(:periods).
      where("reservation_periods.recurring_frequency_unit = 'day'").
      select('reservation_periods.start_minute, reservation_periods.end_minute, EXTRACT(DOW FROM reservation_periods.date) as recurring_on_days').
      group_by(&:recurring_on_days)

    orders.each_pair do |day, periods|
	    ranges = periods.map{ |period| (period.start_minute.to_i..period.end_minute.to_i).step(30).to_a }.flatten
      @schedule[day.to_i] -= ranges.flatten.map {|i| {i => 1}} if @schedule[day.to_i]
    end
  end
end
