# frozen_string_literal: true
require 'test_helper'
module AnalyticsFacade
  class AnalyticsBaseTest < ActiveSupport::TestCase
    context 'As default, analytics' do
      setup do
        @company = FactoryGirl.create(:company)
        @payment = FactoryGirl.create(:paid_payment, company: @company)
        @payment_cad = FactoryGirl.create(:paid_payment, currency: 'CAD', company: @company)
      end

      should 'be USD revenue' do
        @analytics = AnalyticsFacade::AnalyticsBase.build(@company, {})
        assert_equal AnalyticsFacade::RevenueAnalytics, @analytics.class
        assert_equal AnalyticsFacadeDrop, @analytics.to_liquid.class
        assert_equal @payment, @analytics.list.first
        assert_equal 'USD', @analytics.currency
        assert_equal %w(CAD USD).sort, @analytics.currencies.sort
        assert_equal [[0, 0, 0, 0, 0, 0, @payment.total_amount.dollars.to_i]], @analytics.values
      end

      should 'list multipe currencies when multipe currency payment exists' do
        @analytics = AnalyticsFacade::AnalyticsBase.build(@company, currency: 'CAD')
        assert_equal AnalyticsFacade::RevenueAnalytics, @analytics.class
        assert_equal AnalyticsFacadeDrop, @analytics.to_liquid.class
        assert_equal @payment_cad, @analytics.list.first
        assert_equal [[0, 0, 0, 0, 0, 0, @payment_cad.total_amount.dollars.to_i]], @analytics.values
        assert_equal %w(CAD USD).sort, @analytics.currencies.sort
      end

      should 'correctly display chart' do
        @old_payment = FactoryGirl.create(:paid_payment, company: @company, created_at: 2.weeks.ago)
        @analytics = AnalyticsFacade::AnalyticsBase.build(@company, {})
        assert_equal @payment.total_amount + @old_payment.total_amount, @analytics.total
        assert_equal [[0, 0, 0, 0, 0, 0, @payment.total_amount.dollars.to_i]], @analytics.values

        @analytics = AnalyticsFacade::AnalyticsBase.build(@company, period: 'last_30_days')
        assert_equal @payment.total_amount.dollars.to_i + @old_payment.total_amount.dollars.to_i, @analytics.values.flatten.sum
      end

      should 'have proper labels' do
        @analytics = AnalyticsFacade::AnalyticsBase.build(@company, period: 'last_30_days')
        labels = (30.days.ago.to_date..Date.today).map { |date| date.strftime('%b %d') }
        assert_equal labels, @analytics.labels
      end
    end
  end
end
