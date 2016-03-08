# frozen_string_literal: true
class GlobalAdmin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :require_administrator
  before_action :set_platform_context
  before_action :check_if_locked, only: [:new, :create, :edit, :update, :destroy], if: -> { PlatformContext.current.present? }
  skip_before_action :redirect_if_marketplace_password_protected

  layout 'global_admin'

  private

  def require_administrator
    redirect_to root_url unless current_user.admin?
  end

  def check_if_locked
    if PlatformContext.current.instance.locked?
      flash[:notice] = 'You have been redirected because instance is locked, no changes are permitted. All changes have been discarded. You can turn off Master Lock here.'
      redirect_to edit_global_admin_instance_path(PlatformContext.current.instance)
    end
  end

  def set_platform_context
    if params[:instance_id].present?
      PlatformContext.current = PlatformContext.new(Instance.find(params[:instance_id]))
      PlatformContext.scope_to_instance
    elsif GlobalAdmin::InstancesController === self && params[:id].present?
      PlatformContext.current = PlatformContext.new(Instance.find(params[:id]))
    elsif params[:transactable_type_id]
      PlatformContext.current = PlatformContext.new(TransactableType.unscoped.find(params[:transactable_type_id]).instance)
    else
      PlatformContext.clear_current
    end
  end
end
