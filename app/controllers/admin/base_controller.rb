class Admin::BaseController < ApplicationController
  before_filter :require_administrator

  layout 'admin'

  private

  def require_administrator
    unless current_user && current_user.admin?
      redirect_to root_url
    end
  end
end

