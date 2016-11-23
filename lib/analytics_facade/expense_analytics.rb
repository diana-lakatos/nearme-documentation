# frozen_string_literal: true
module AnalyticsFacade
  class ExpenseAnalytics < AnalyticsFacade::AnalyticsBase
    def collection
      @collection ||= scope.creator.payments.paid
    end

    def base_scope
      return @base_scope if @base_scope.present?

      @base_scope = collection.where(currency: currency)
      @base_scope = @base_scope.where(payment_transfer_id: options[:payment_transfer_id]) if options[:payment_transfer_id]
      @base_scope
    end

    def chart_data
      chart_scope.select(
        "(payments.created_at::timestamp at time zone \'#{Time.zone}\')::DATE AS chart_date, sum(total_amount_cents) / 100 as chart_points"
      ).group('chart_date').order('chart_date ASC')
    end

    def total
      Money.new base_scope.sum(:total_amount_cents), currency
    end
  end
end
