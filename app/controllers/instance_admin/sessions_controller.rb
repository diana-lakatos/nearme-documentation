class InstanceAdmin::SessionsController < SessionsController
  skip_before_filter :authenticate_user!
  skip_before_filter :authorize_user!
  skip_before_filter :redirect_if_marketplace_password_protected
  skip_before_filter :redirect_if_maintenance_mode_enabled

  layout 'instance_admin'

  def new
    redirect_to(instance_admin_path) && return if user_signed_in?
    super
  end
end
