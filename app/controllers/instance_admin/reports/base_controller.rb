class InstanceAdmin::Reports::BaseController < InstanceAdmin::BaseController
  def index
    redirect_to instance_admin_reports_listings_path
  end
end
