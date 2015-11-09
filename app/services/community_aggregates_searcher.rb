class CommunityAggregatesSearcher

  def initialize(params)
    default_start_date = DateTime.now.utc.weeks_ago(1).at_beginning_of_week
    default_end_date = DateTime.now.utc.weeks_ago(1).at_end_of_week

    @start_date = DateTime.strptime(params[:week_start], '%Y-W%W').at_beginning_of_week rescue @start_date = default_start_date
    @end_date = DateTime.strptime(params[:week_end], '%Y-W%W').at_end_of_week rescue @end_date = default_end_date
  end

  def search
    CommunityReportingAggregate.where('start_date >= ? AND end_date <= ?', @start_date, @end_date + 1.day).order('start_date ASC')
  end

end

