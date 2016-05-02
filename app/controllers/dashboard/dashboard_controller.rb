class Dashboard::DashboardController < ApplicationController
  before_filter :authenticate_user!

  def index
    company = current_user.companies.first

    if buyable?
      redirect_to company ? dashboard_company_orders_received_index_path : dashboard_orders_path
    else
      if company
        redirect_to get_redirect_url_when_company_present
      else
        redirect_to dashboard_user_reservations_path
      end
    end
  end

  private

  def get_redirect_url_when_company_present
    if !HiddenUiControls.find('dashboard/host_reservations').hidden?
      dashboard_company_host_reservations_path
    elsif platform_context.instance.subscribable? && !HiddenUiControls.find('dashboard/host_recurring_bookings').hidden?
      dashboard_company_host_recurring_bookings_path
    else
      dashboard_user_reservations_path
    end
  end

end
