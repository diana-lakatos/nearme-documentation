class DateTimeHandler

  def initialize
  end

  def convert_to_datetime(object)
    case object
    when String
      Time.zone.local_to_utc(DateTime.strptime(object, I18n.t('datepicker.dformat'))).in_time_zone rescue nil
    when Date, DateTime, ActiveSupport::TimeWithZone, nil
      object
    else
      raise NotImplementedError.new("Can't convert #{object.inspect} to datetime")
    end
  end

  def convert_to_date(object)
    case object
    when String
      DateTime.strptime(object, I18n.t('datepicker.dformat')) rescue nil
    when Date, DateTime, ActiveSupport::TimeWithZone, nil
      object
    else
      raise NotImplementedError.new("Can't convert #{object.inspect} to datetime")
    end
  end

  def convert_to_time(object)
    case object
    when String
      Time.zone.local_to_utc(DateTime.strptime(object, I18n.t('timepicker.dformat'))).in_time_zone rescue nil
    when Date, DateTime, ActiveSupport::TimeWithZone, nil
      object
    else
      raise NotImplementedError.new("Can't convert #{object.inspect} to time")
    end
  end

  def convert_to_string(object)
    case object
    when Date, DateTime, ActiveSupport::TimeWithZone, Time
      I18n.l(object, format: :inputs) rescue nil
    when String, nil
      object
    else
      raise NotImplementedError.new("Can't convert #{object.inspect} (#{object.class.name}) to string")
    end
  end
end

