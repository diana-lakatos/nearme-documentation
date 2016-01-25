class AvailabilityRule::HourlyListingStatus
  def initialize(listing, date)
    @listing = listing
    @date = date
    @schedule = {}

    if @listing.availability.open_on?(:date => @date)
      @rules = @listing.availability.rules_for_day(@date.wday)
      @rules.each do |rule|
        (rule.day_open_minute..rule.day_close_minute).step(15) do |minute|
          @schedule[minute] = @listing.quantity_for(date)
        end
      end
      build_time_quantities
    end
  end

  def as_json
    @schedule
  end

  def build_time_quantities
    @listing.reservations.confirmed.joins(:periods).
     where(:reservation_periods => { :date => @date }).
     select('reservations.quantity as quantity_booked, reservation_periods.start_minute, reservation_periods.end_minute').
     each do |period|
      if period.start_minute.present?
        range = (period.start_minute.to_i..period.end_minute.to_i)
        @schedule.keys.each { |k| @schedule[k] -= period.quantity_booked.to_i if range.include?(k.to_i)  }
      else
        @schedule.keys.each { |k| @schedule[k] -= period.quantity_booked.to_i }
      end
    end
  end

end
