# frozen_string_literal: true
class AnalyticsFacade::ListingAnalytics < AnalyticsFacade::AnalyticsBase
  def base_scope
    @base_scope ||= scope.listings
  end

  def chart_data
    chart_scope.select(
      "(transactables.created_at::timestamp at time zone \'#{Time.zone}\')::DATE AS chart_date, count(*) as chart_points"
    ).group('chart_date').order('chart_date ASC')
  end
end
