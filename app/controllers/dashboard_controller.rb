class DashboardController < ApplicationController
  before_filter :require_user

  def index
    @workspaces = current_user.workplaces.all
  end
end
