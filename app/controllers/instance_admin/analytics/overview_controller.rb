# frozen_string_literal: true
class InstanceAdmin::Analytics::OverviewController < InstanceAdmin::Analytics::BaseController
  def show
    @analytics = AnalyticsFacade::AnalyticsBase.build(current_instance, params)
  end
end
