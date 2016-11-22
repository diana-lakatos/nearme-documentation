# frozen_string_literal: true
class InstanceAdmin::Analytics::OverviewController < InstanceAdmin::Analytics::BaseController
  before_action :fetch_currencies

  def show
    @chart_types = ChartDecorator::ADMIN_CHARTS
    params[:chart_type] ||= @chart_types.first
    @chart = ChartDecorator.new(current_instance, params).to_liquid
  end

  def fetch_currencies
    @currencies = current_instance.payments.group(:currency).select(:currency).map(&:currency)
    params[:currency] ||= @currencies.first
  end
end
