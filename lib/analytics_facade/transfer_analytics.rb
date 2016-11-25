# frozen_string_literal: true
module AnalyticsFacade
  class TransferAnalytics < AnalyticsFacade::AnalyticsBase
    def collection
      @collection ||= scope.payment_transfers
    end

    def base_scope
      @base_scope ||= @collection.where(currency: currency)
    end

    def chart_data
      chart_scope.select(
        "(payment_transfers.created_at::timestamp at time zone \'#{Time.zone}\')::DATE AS chart_date, sum(amount_cents) / 100 as chart_points"
      ).group('chart_date').order('chart_date ASC')
    end

    def total
      Money.new base_scope.sum(:amount_cents), currency
    end
  end
end
