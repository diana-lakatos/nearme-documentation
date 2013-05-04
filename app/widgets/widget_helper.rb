class WidgetHelper

  TIME_LIMIT = 7

  def initialize(object)
    @object = object
  end

  def get_count
    @object.count
  end

  def get_secondary_count
    # Geckoboard makes the following calculation: ((first_number-second_number)/second_number)*100%
    # So if total count for today 30.04.2013 is 100 , and 80 was the total count until the previous week [ 23.04.2013 ],
    # we will obtain: 100% * (100-80)/80 = 100% * 20/80 = 25%. Which is correct - since last week, we got +25% <objects>
    # If we used created_at >= instead of <, the calculation would be 100% * (100-20)/20 = 400% and this is wrong
    @object.count(:conditions => ["created_at < ?", (Time.now-TIME_LIMIT.days).utc])
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
    @result_hash[:y_axis] = [@result_hash[:items].first, @result_hash[:items].last]
    @result_hash
  end

  def get_date_for_days_ago(days_ago)
    (Time.now-days_ago.days).utc.to_date
  end

  def get_count_until_date(date)
    @object.count(:conditions => ["created_at < ?", date+1.day])
  end

end
