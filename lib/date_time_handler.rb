# frozen_string_literal: true
class DateTimeHandler
  def initialize
  end

  def convert_to_datetime(object)
    case object
    when String
      begin
        Time.zone.local_to_utc(DateTime.strptime(object, I18n.t('datepicker.dformat'))).in_time_zone
      rescue
        nil
      end
    when Date, DateTime, ActiveSupport::TimeWithZone, nil
      object
    else
      raise NotImplementedError, "Can't convert #{object.inspect} to datetime"
    end
  end

  def convert_to_date(object)
    case object
    when String
      begin
        DateTime.strptime(object, I18n.t('datepicker.dformat'))
      rescue
        nil
      end
    when Date, DateTime, ActiveSupport::TimeWithZone, nil
      object
    else
      raise NotImplementedError, "Can't convert #{object.inspect} to datetime"
    end
  end

  def convert_to_time(object)
    case object
    when String
      begin
        Time.zone.local_to_utc(DateTime.strptime(object, I18n.t('timepicker.dformat'))).in_time_zone
      rescue
        nil
      end
    when Date, DateTime, ActiveSupport::TimeWithZone, nil
      object
    else
      raise NotImplementedError, "Can't convert #{object.inspect} to time"
    end
  end

  def convert_to_string(object)
    case object
    when Date, DateTime, ActiveSupport::TimeWithZone, Time
      begin
        I18n.l(object, format: I18n.t('datepicker.dformat'))
      rescue
        nil
      end
    when String, nil
      object
    else
      raise NotImplementedError, "Can't convert #{object.inspect} (#{object.class.name}) to string"
    end
  end
end
