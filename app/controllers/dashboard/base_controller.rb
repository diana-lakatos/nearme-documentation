class Dashboard::BaseController < ApplicationController
  layout 'dashboard'

  before_filter :authenticate_user!
  before_filter :find_company
  before_filter :redirect_unless_registration_completed

  DASHBOARD_CONTROLLERS = [
    "dashboard/orders",
    "dashboard/user_reservations",
    "dashboard/user_messages",
    "dashboard/companies",
    "dashboard/products",
    "dashboard/transactables",
    "dashboard/payouts",
    "dashboard/orders_received",
    "dashboard/host_reservations",
    "dashboard/transfers",
    "dashboard/analytics",
    "dashboard/users",
    "dashboard/waiver_agreement_templates",
    "dashboard/white_labels",
    "dashboard/tickets",
    "registrations/edit",
    "registrations/social_accounts",
    "dashboard/blog",
    "registrations/show#buy-sell",
    "registrations/show#services",
    "registrations/show#reviews",
    "registrations/show#blog_posts",
    "dashboard/reviews",
    'dashboard/wish_list_items'
  ]

  private

  def find_company
    @company = current_user.try(:companies).try(:first).try(:decorate)
  end

  def redirect_unless_registration_completed
    unless current_user.registration_completed?
      flash[:warning] = t('flash_messages.dashboard.add_your_company')
      redirect_to transactable_type_new_space_wizard_path(TransactableType.first)
    end
  end

end
