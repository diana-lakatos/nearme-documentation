# frozen_string_literal: true
class Admin::SessionsController < SessionsController
  skip_before_action :authenticate_user!
  skip_before_action :authorize_user!
  skip_before_action :redirect_if_marketplace_password_protected

  layout 'admin/login'

  def new
    redirect_to(admin_path) && return if user_signed_in?
    super
  end
end
