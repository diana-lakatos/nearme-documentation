class WidgetHelper

  TIME_LIMIT = 7

  def initialize(object)
    @object = object
  end

  def get_count
    @object.count
  end

  def get_count_for_date(start_date)
    end_date = start_date+1.day
    @object.count(:conditions => ["created_at >= ? AND created_at < ?", start_date, end_date])
  end

  def get_date_for_days_ago(days_ago)
    (Time.now-days_ago.days).utc.to_date
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
      current_count += get_count_for_date(date)
      @result_hash[:items] << current_count
      @result_hash[:x_axis] << date.strftime('%d-%m')
    end
    @result_hash[:y_axis] = [0, current_count+2]
    @result_hash
  end

  def get_secondary_count
    @old_count =  get_count
    @only_new_count = @object.count(:conditions => ["created_at >= ?", (Time.now-TIME_LIMIT.days).utc])
    get_progress
  end

  def get_progress
    @only_old_count = @old_count - @only_new_count
    (@only_old_count > 0 ? (@only_new_count.to_f/@only_old_count.to_f)*100 : nil)
  end
end
