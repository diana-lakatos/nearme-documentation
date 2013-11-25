class InstanceAdmin::BaseController < ApplicationController
  before_filter :auth_user!
  before_filter :authorize_user!

  def index
    redirect_to instance_admin_analytics_path
  end

  layout 'instance_admin'

  private

  def auth_user!
    unless user_signed_in?
      session[:user_return_to] = request.path
      redirect_to instance_admin_login_path
    end
  end

  def authorize_user!
    @authorizer ||= InstanceAdmin::Authorizer.new(current_user, platform_context)
    if !(@authorizer.instance_admin?)
      redirect_to root_path
    elsif !@authorizer.authorized?(permitting_controller_class)
      if @authorizer.authorized?(InstanceAdmin::AnalyticsController)
        flash[:warning] = 'Sorry, you do not have permission to view chosen page!'
        redirect_to instance_admin_path
      else
        redirect_to root_path
      end
    end
  end

  def permitting_controller_class
    self.class
  end

  def instance_admin_roles
    @instance_admin_roles ||= ([InstanceAdminRole.administrator_role, InstanceAdminRole.default_role] + platform_context.instance.instance_admin_roles).compact
  end
  helper_method :instance_admin_roles
end
