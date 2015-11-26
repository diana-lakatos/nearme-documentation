class HourlyPresenter
  include ActionView::Helpers::TextHelper
  attr_accessor :date, :start_minute, :end_minute

  def initialize(date, start_minute, end_minute, timezone=nil)
    @timezone = timezone
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
      start_time = I18n.l(start_minute_of_day_to_time, format: :start_hours).strip
      end_time = I18n.l(end_minute_of_day_to_time, format: :end_hours).strip

      if show_date
        ('%s %s-%s (%0.2f %s)' % [I18n.l(date, format: :short), start_time, end_time, hours, 'hour'.pluralize(hours.to_i)]).html_safe
      else
        ('%s-%s<br />(%0.2f %s)' % [start_time, end_time, hours, 'hour'.pluralize(hours.to_i)]).html_safe
      end
    end
  end

  def hourly_summary(show_date = false, options = {})
    options[:separator] ||= ' '
    start_time = I18n.l(start_minute_of_day_to_time, format: :start_hours).strip
    end_time = I18n.l(end_minute_of_day_to_time, format: :end_hours).strip

    if hours.zero?
      if show_date
        ('%s%s%s' % [I18n.l(date, format: :short), options[:separator], start_time]).html_safe
      else
        ('%s' % [start_time]).html_safe
      end
    else
      timezone_info = (@timezone.present? && @timezone != Time.zone.name) ? " #{@timezone} Time zone" : ""

      if show_date
        ('%s%s%s&ndash;%s%s(%0.2f %s)%s' % [I18n.l(date, format: :short), options[:separator], start_time, end_time, options[:separator], hours, 'hour'.pluralize(hours.to_i), timezone_info ]).html_safe
      else
        ('%s&ndash;%s<br />(%0.2f %s)%s' % [start_time, end_time, hours, 'hour'.pluralize(hours.to_i), timezone_info]).html_safe
      end
    end
  end

  def minute_of_day_to_time(minute)
    hour = minute / 60
    min  = minute % 60
    day = Time.zone.today.day
    if hour >= 24
      hour -= 24
      day += 1
    end
    Time.zone.local(Time.zone.today.year, Time.zone.today.month, day, hour, min)
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

