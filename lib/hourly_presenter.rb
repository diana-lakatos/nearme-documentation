class HourlyPresenter
  include ActionView::Helpers::TextHelper
  attr_accessor :date, :start_minute, :end_minute

  def initialize(date, start_minute, end_minute)
    @date = date
    @start_minute = start_minute
    @end_minute = end_minute
  end

  def hourly_summary_no_html(show_date = false)
    if hours.zero?
      if show_date
        "#{I18n.l(date, format: :short)} #{start_minute_of_day_to_time.strftime("%l:%M").strip}"
      else
        start_minute_of_day_to_time.strftime("%l:%M").strip
      end
    else
      start_time = start_minute_of_day_to_time.strftime("%l:%M").strip
      end_time = end_minute_of_day_to_time.strftime("%l:%M%P").strip
      start_time_suffix = start_minute_of_day_to_time.strftime("%P").strip
      end_time_suffix = end_minute_of_day_to_time.strftime("%P").strip

      start_time += start_time_suffix unless start_time_suffix == end_time_suffix

      if show_date
        ('%s %s-%s (%0.2f %s)' % [I18n.l(date, format: :short), start_time, end_time, hours, 'hour'.pluralize(hours.to_i)]).html_safe
      else
        ('%s-%s<br />(%0.2f %s)' % [start_time, end_time, hours, 'hour'.pluralize(hours.to_i)]).html_safe
      end
    end
  end

  def hourly_summary(show_date = false, options = {})
    options[:separator] ||= ' '
    start_time = start_minute_of_day_to_time.strftime("%l:%M").strip
    end_time = end_minute_of_day_to_time.strftime("%l:%M%P").strip
    start_time_suffix = start_minute_of_day_to_time.strftime("%P").strip
    end_time_suffix = end_minute_of_day_to_time.strftime("%P").strip

    start_time += start_time_suffix unless start_time_suffix == end_time_suffix

    if hours.zero?
      if show_date
        ('%s%s%s' % [I18n.l(date, format: :short), options[:separator], start_time]).html_safe
      else
        ('%s' % [start_time]).html_safe
      end
    else
      if show_date
        ('%s%s%s&ndash;%s%s(%0.2f %s)' % [I18n.l(date, format: :short), options[:separator], start_time, end_time, options[:separator], hours, 'hour'.pluralize(hours.to_i)]).html_safe
      else
        ('%s&ndash;%s<br />(%0.2f %s)' % [start_time, end_time, hours, 'hour'.pluralize(hours.to_i)]).html_safe
      end
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

  def hours
    if start_minute && end_minute
      (end_minute - start_minute) / 60.0
    else
      0
    end
  end

end

