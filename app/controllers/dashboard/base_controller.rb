class Dashboard::BaseController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_company

  protected

  def layout_name
    dashboard_or_community_layout
  end

  private

  def find_company
    @company = current_user.try(:companies).try(:first).try(:decorate)
  end
end
