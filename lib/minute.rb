class Minute
  def initialize(minutes, date = Time.zone.now.to_date)
    @minutes = minutes.to_i
    @date = date
  end

  def to_time
    @date.beginning_of_day + @minutes.minutes
  end

  def to_time_in_timezone(timezone)
    Time.use_zone(timezone) do
      @date.beginning_of_day + @minutes.minutes
    end
  end
end
