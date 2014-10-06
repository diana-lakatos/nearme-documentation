class InstanceAdmin::Analytics::BaseController < InstanceAdmin::BaseController
  def index
    redirect_to instance_admin_analytics_overview_path
  end
end
