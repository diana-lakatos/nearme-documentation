class Admin::BaseController < ApplicationController
  before_filter :authenticate_user!
  before_filter :require_administrator
  before_filter :set_platform_context
  skip_before_filter :redirect_if_marketplace_password_protected

  layout 'admin'

  private

  def require_administrator
    redirect_to root_url unless current_user.admin?
  end

  def set_platform_context
    if params[:instance_id].present?
      PlatformContext.current = PlatformContext.new(Instance.find(params[:instance_id]))
      PlatformContext.scope_to_instance
    else
      PlatformContext.clear_current
    end

  end

end

