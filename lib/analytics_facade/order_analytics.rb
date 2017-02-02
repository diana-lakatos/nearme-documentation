# frozen_string_literal: true
module AnalyticsFacade
  class OrderAnalytics < AnalyticsFacade::AnalyticsBase
    def base_scope
      @base_scope ||= scope.orders.where(state: ['confirmed', 'completed'])
    end

    def chart_data
      chart_scope.select(
        "(orders.created_at::timestamp at time zone \'#{Time.zone}\')::DATE AS chart_date, count(quantity) as chart_points"
      ).group('chart_date').order('chart_date ASC')
    end

    def total
      base_scope.sum(:quantity)
    end
  end
end
