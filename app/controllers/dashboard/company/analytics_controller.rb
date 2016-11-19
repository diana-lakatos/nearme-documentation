# frozen_string_literal: true
class Dashboard::Company::AnalyticsController < Dashboard::Company::BaseController
  before_action :prepare_params

  def show
    @analytics = AnalyticsFacade::AnalyticsBase.build(@company, params)
  end

  def prepare_params
    params[:chart_type] = params[:analytics_mode]
  end
end
