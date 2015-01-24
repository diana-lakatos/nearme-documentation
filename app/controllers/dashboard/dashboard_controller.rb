class Dashboard::DashboardController < ApplicationController
  before_filter :authenticate_user!

  def index
    company = current_user.companies.first

    if buyable?
      redirect_to company ? dashboard_orders_received_index_path : dashboard_orders_path
    else
      redirect_to company ? dashboard_host_reservations_path : dashboard_user_reservations_path
    end
  end
end
