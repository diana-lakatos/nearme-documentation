class Dashboard::DashboardController < ApplicationController
  before_filter :authenticate_user!

  def index
    company = current_user.companies.first
    redirect_to company ? dashboard_company_orders_received_index_path : dashboard_orders_path
  end
end
