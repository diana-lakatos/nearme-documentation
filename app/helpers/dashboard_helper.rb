module DashboardHelper

  def in_new_listing?
    (params[:action] == 'new' || params[:action] == 'edit') && params[:controller].include?('listings') && params[:id].blank?
  end

  def in_new_or_edit?
    ['new', 'create', 'edit', 'update'].include?(params[:action])
  end

  def dashboard_company_nav_class(company)
    classes = []

    if @location && @location.company == company
      classes << 'expanded'
    elsif @company && @company == company
      classes << 'active'
    end

    classes.join ' '
  end

  def dashboard_location_nav_class(location)
    classes = []

    if @location && @location == location
      classes << 'active'
    end

    classes.join ' '
  end

  def guest_filter_class(guest_list, filter)
    guest_list.state == filter ? 'btn-gray active' : 'btn-gray-darker'
  end

  def periods_dates(periods)
    periods.map(&:date).map{ |date| date.to_s(:db) }
  end

  def no_reservations_info_for_state(state)
    case state.to_s
    when 'unconfirmed'
      'You have no unconfirmed reservations.'
    when 'confirmed'
      "You haven't confirmed any reservations yet."
    when 'archived'
      "You don't have any archived reservations."
    end
  end

  def mobile_menu_caption
    controller = params[:controller]
    action = params[:action]

    return t('dashboard.nav.my_orders') if controller == 'dashboard/orders' || controller == 'dashboard/user_reservations'
    return t('dashboard.nav.messages') if controller.include? 'user_messages'
    return t('dashboard.nav.shop_details') if controller.include? 'companies'
    return t('dashboard.nav.listings') if %w(dashboard/products dashboard/transactables).include? controller
    return t('dashboard.nav.payout') if controller.include? 'payouts'
    return t('dashboard.nav.orders_received') if controller == 'dashboard/orders_received' || controller == 'dashboard/host_reservations'
    return t('dashboard.nav.payment_transfers') if controller.include? 'transfers'
    return t('dashboard.nav.analytics') if controller.include? 'analytics'
    return t('dashboard.nav.manage_admins') if controller.include? 'users'
    return t('dashboard.nav.waiver_agreements') if controller.include? 'waiver_agreement_templates'
    return t('dashboard.nav.white_label') if controller.include? 'white_label'
    return t('dashboard.nav.edit_profile') if controller.include?('registration') && action.include?('edit')
    return t('dashboard.nav.trust_verification') if controller.include?('registration') && action.include?('social_accounts')

    t('dashboard.nav.menu')
  end
end
