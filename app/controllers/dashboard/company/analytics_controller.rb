# frozen_string_literal: true
class Dashboard::Company::AnalyticsController < Dashboard::Company::BaseController
  before_action :fetch_currencies, :prepare_params

  def show
    @chart = ChartDecorator.new(@company, params).to_liquid
  end

  def fetch_currencies
    @currencies = @company.payments.group(:currency).select(:currency).map(&:currency)
  end

  def prepare_params
    params[:chart_type] ||= params[:analytics_mode]
    params[:currency] ||= @currencies.first
  end
end
