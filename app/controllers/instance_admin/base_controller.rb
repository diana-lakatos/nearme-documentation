class InstanceAdmin::BaseController < ApplicationController
  before_filter :authenticate_user!
  # TODO: further authentication will be introduced later

  def index
    redirect_to instance_admin_analytics_path
  end

  layout 'instance_admin'

end

