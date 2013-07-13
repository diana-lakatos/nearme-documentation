class Admin::BaseController < ApplicationController
  before_filter :authenticate_user!
  before_filter :require_administrator

  layout 'admin'

  private

  def require_administrator
    redirect_to root_url unless current_user.admin?
  end
end

