class Dashboard::BaseController < ApplicationController
  layout 'dashboard'

  before_filter :authenticate_user!
  before_filter :find_company

  DASHBOARD_CONTROLLERS = [
    "dashboard/blog",
    "dashboard/company/analytics",
    "dashboard/company/host_reservations",
    "dashboard/company/orders_received",
    "dashboard/company/payouts",
    "dashboard/company/products",
    "dashboard/company/transactables",
    "dashboard/company/transfers",
    "dashboard/company/users",
    "dashboard/company/waiver_agreement_templates",
    "dashboard/company/white_labels",
    "dashboard/companies",
    "dashboard/orders",
    "dashboard/reviews",
    "dashboard/tickets",
    "dashboard/user_reservations",
    "dashboard/user_messages",
    "registrations/edit",
    "registrations/social_accounts",
    "registrations/show#buy-sell",
    "registrations/show#services",
    "registrations/show#reviews",
    "registrations/show#blog_posts",
  ]

  private

  def find_company
    @company = current_user.try(:companies).try(:first).try(:decorate)
  end
end
