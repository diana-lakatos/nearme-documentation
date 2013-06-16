class AvailabilityRule::HourlyListingStatus
  def initialize(listing, date)
    @listing = listing
    @date = date
    @schedule = {}

    if @listing.availability.open_on?(:date => @date)
      @rule = @listing.availability.rule_for_day(@date.wday)
      (@rule.day_open_minute..@rule.day_close_minute).step(15) do |minute|
        @schedule[minute] = @listing.quantity_for(date)
      end
      build_time_quantities
    end
  end

  def as_json
    @schedule
  end

  def build_time_quantities
    @listing.reservations.not_rejected_or_cancelled.joins(:periods).
     where(:reservation_periods => { :date => @date }).
     select('reservations.quantity as quantity_booked, reservation_periods.start_minute, reservation_periods.end_minute').
     each do |period|
      if period.start_minute.present?
        (period.start_minute.to_i..period.end_minute.to_i).step(15) do |minute|
          @schedule[minute] -= period.quantity_booked.to_i
        end
      else
        (@rule.day_open_minute..@rule.day_close_minute).step(15) do |minute|
          @schedule[minute] -= period.quantity_booked.to_i
        end
      end
    end
  end

end
