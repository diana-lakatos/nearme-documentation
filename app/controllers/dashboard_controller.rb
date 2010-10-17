class DashboardController < ApplicationController
  before_filter :require_user

  def index
    @workspaces = current_user.workplaces.all
    @your_bookings = current_user.bookings.upcoming
    @workplace_bookings = current_user.workplace_bookings.upcoming
  end
end
