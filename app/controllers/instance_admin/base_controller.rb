class InstanceAdmin::BaseController < ApplicationController
  layout 'instance_admin'

  before_filter :auth_user!
  before_filter :authorize_user!
  skip_before_filter :redirect_if_marketplace_password_protected

  def index
    first_permission_have_access_to = @authorizer.first_permission_have_access_to
    redirect_to url_for([:instance_admin, first_permission_have_access_to])
  end

  private

  def auth_user!
    unless user_signed_in?
      session[:user_return_to] = request.path
      redirect_to instance_admin_login_path
    end
  end

  def authorize_user!
    @authorizer ||= InstanceAdminAuthorizer.new(current_user, platform_context)
    if !(@authorizer.instance_admin?)
      flash[:warning] = t('flash_messages.authorizations.not_authorized')
      redirect_to root_path
    elsif !@authorizer.authorized?(permitting_controller_class)
      first_permission_have_access_to = @authorizer.first_permission_have_access_to
      if first_permission_have_access_to
        flash[:warning] = t('flash_messages.authorizations.not_authorized')
        redirect_to url_for([:instance_admin, first_permission_have_access_to])
      else
        redirect_to root_path
      end
    end
  rescue InstanceAdminAuthorizer::UnassignedInstanceAdminRoleError => e
    notify_raygun_about_exception(e)
    flash[:warning] = t('flash_messages.authorizations.not_authorized')
    redirect_to root_path
  end

  def permitting_controller_class
    self.class.to_s.deconstantize.demodulize
  end

  def instance_admin_roles
    @instance_admin_roles ||= ([InstanceAdminRole.administrator_role, InstanceAdminRole.default_role] + platform_context.instance.instance_admin_roles).compact
  end
  helper_method :instance_admin_roles
end
