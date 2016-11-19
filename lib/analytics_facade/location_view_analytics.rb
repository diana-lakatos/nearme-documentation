# frozen_string_literal: true
class AnalyticsFacade::LocationViewAnalytics < AnalyticsFacade::AnalyticsBase
  def base_scope
    @base_scope ||= scope.locations_impressions
  end

  def chart_data
    chart_scope.select(
      "(impressions.created_at::timestamp at time zone \'#{Time.zone}\')::DATE AS chart_date, count(*) as chart_points"
    ).group('chart_date').order('chart_date ASC')
  end
end
