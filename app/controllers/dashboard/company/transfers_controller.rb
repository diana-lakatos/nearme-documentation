# frozen_string_literal: true
class Dashboard::Company::TransfersController < Dashboard::Company::BaseController
  before_action :fetch_currencies
  before_action :prepare_params

  def show
    @analytics = AnalyticsFacade::AnalyticsBase.build(@company, params.merge(chart_type: 'transfers'))
  end

  def fetch_currencies
    @currencies = @company.payment_transfers.group(:currency).select(:currency).map(&:currency)
  end

  def prepare_params
    params[:currency] ||= @currencies.first
  end
end
