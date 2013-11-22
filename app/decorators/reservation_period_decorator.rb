class ReservationPeriodDecorator < Draper::Decorator
  delegate_all

  def hourly_summary(show_date = false)
    start_time = start_minute_of_day_to_time.strftime("%l:%M").strip
    end_time = end_minute_of_day_to_time.strftime("%l:%M%P").strip
    start_time_suffix = start_minute_of_day_to_time.strftime("%P").strip
    end_time_suffix = end_minute_of_day_to_time.strftime("%P").strip

    start_time += start_time_suffix unless start_time_suffix == end_time_suffix

    if show_date
      formatted_date = date.strftime("%B %-e")
      ('%s %s&ndash;%s (%0.2f hours)' % [formatted_date, start_time, end_time, hours]).html_safe
    else
      ('%s&ndash;%s<br />(%0.2f hours)' % [start_time, end_time, hours]).html_safe
    end
  end

  def minute_of_day_to_time(minute)
    hour = minute / 60
    min  = minute % 60
    Time.zone.local(Time.zone.today.year, Time.zone.today.month, Time.zone.today.day, hour, min)
  end

  def start_minute_of_day_to_time
    minute_of_day_to_time(start_minute)
  end

  def end_minute_of_day_to_time
    minute_of_day_to_time(end_minute)
  end

end
