class CommunityAggregatesSearcher
  def initialize(params)
    default_start_date = Time.now.utc.weeks_ago(1).at_beginning_of_week
    default_end_date = Time.now.utc.weeks_ago(1).at_end_of_week

    @start_date = parse_week_from_params(params[:week_start]).at_beginning_of_week rescue @start_date = default_start_date
    @end_date = parse_week_from_params(params[:week_end]).at_end_of_week rescue @end_date = default_end_date
  end

  def search
    CommunityReportingAggregate.where('start_date >= ? AND end_date <= ?', @start_date, @end_date).order('start_date ASC')
  end

  protected

  def parse_week_from_params(formatted_week)
    date_parsed = DateTime.strptime(formatted_week, '%Y-W%W')
    # We want to emulate %V which is non-functional for strptime
    if date_parsed.at_beginning_of_year.wday != 1
      date_parsed = date_parsed.weeks_ago(1)
    end

    date_parsed.to_time.utc
  end
end
