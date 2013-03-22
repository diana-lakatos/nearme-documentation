class WidgetHelper

  TIME_LIMIT = 7

  def initialize(object)
    @object = object
  end

  def get_count
    @object.count
  end

  def get_secondary_count
    @object.count(:conditions => ["created_at >= ?", (Time.now-TIME_LIMIT.days).utc])
  end

  def get_line_data
    @result_hash = {
      :items => [],
      :x_axis => [],
      :y_axis => [],
      :colour => "989898"
    }
    current_count = 0
    for days_ago in 1..TIME_LIMIT
      date = get_date_for_days_ago(TIME_LIMIT - days_ago)
      @result_hash[:items] << get_count_until_date(date)
      @result_hash[:x_axis] << date.strftime('%d-%m')
    end
    @result_hash[:y_axis] = [0, @result_hash[:items].last+@result_hash[:items].last*0.1]
    @result_hash
  end

  def get_date_for_days_ago(days_ago)
    (Time.now-days_ago.days).utc.to_date
  end

  def get_count_until_date(date)
    @object.count(:conditions => ["created_at < ?", date+1.day])
  end

end
