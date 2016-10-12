class Admin::BaseController < ApplicationController
  before_filter :authenticate_user!
  before_filter :require_administrator
  before_filter :set_platform_context
  before_filter :check_if_locked, only: [:new, :create, :edit, :update, :destroy], if: -> { PlatformContext.current.present? }
  skip_before_filter :redirect_if_marketplace_password_protected

  layout 'admin'

  private

  def require_administrator
    redirect_to root_url unless current_user.admin?
  end

  def check_if_locked
    if PlatformContext.current.instance.locked?
      flash[:notice] = 'You have been redirected because instance is locked, no changes are permitted. All changes have been discarded. You can turn off Master Lock here.'
      redirect_to edit_admin_instance_path(PlatformContext.current.instance)
    end
  end

  def set_platform_context
    if params[:instance_id].present?
      PlatformContext.current = PlatformContext.new(Instance.find(params[:instance_id]))
      PlatformContext.scope_to_instance
    elsif Admin::InstancesController === self && params[:id].present?
      PlatformContext.current = PlatformContext.new(Instance.find(params[:id]))
    elsif params[:transactable_type_id]
      PlatformContext.current = PlatformContext.new(TransactableType.unscoped.find(params[:transactable_type_id]).instance)
    else
      PlatformContext.clear_current
    end
  end
end
