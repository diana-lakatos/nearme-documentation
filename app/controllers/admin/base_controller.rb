class Admin::BaseController < ApplicationController
  before_filter :require_administrator

  layout 'admin'

  private

  def require_administrator
    redirect_to root_url if !current_user || !current_user.admin?
  end
end

