class InstanceAdmin::Analytics::BaseController < InstanceAdmin::BaseController
  CONTROLLERS = { 'overview' => { default_action: 'show' }}

  def index
    redirect_to instance_admin_analytics_overview_path
  end
end
