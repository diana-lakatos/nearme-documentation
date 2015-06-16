module DashboardHelper

  def in_new_listing?
    (params[:action] == 'new' || params[:action] == 'edit') && params[:controller].include?('listings') && params[:id].blank?
  end

  def in_new_or_edit?
    ['new', 'create', 'edit', 'update'].include?(params[:action])
  end

  def analytics_options_for_select
    if PlatformContext.current.instance.buyable?
      options_for_select([[t('dashboard.analytics.revenue'), 'revenue'], [t('dashboard.analytics.orders'), 'orders'], [t('dashboard.analytics.product_views'), 'product_views']], @analytics_mode)
    else
      options_for_select([[t('dashboard.analytics.revenue'), 'revenue'], [t('dashboard.analytics.bookings'), 'bookings'], [t('dashboard.analytics.location_views'), 'location_views']], @analytics_mode)
    end
  end

  def no_purchases_yet_text
    if PlatformContext.current.instance.buyable?
      t('dashboard.analytics.no_purchases_yet')
    else
      t('dashboard.analytics.no_reservations_yet')
    end
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

  def has_active_rating_system?
    @rating_systems ? @rating_systems[:active_rating_systems].present? : false
  end

  def guest_filter_class(guest_list, filter)
    guest_list.state == filter ? 'btn-gray active' : 'btn-gray-darker'
  end

  def periods_dates(periods)
    periods.map(&:date).map { |date| date.to_s(:db) }
  end

  def no_reservations_info_for_state(state)
    case state.to_s
    when 'unconfirmed'
      t('dashboard.host_reservations.no_unconfirmed_reservations')
    when 'confirmed'
      t('dashboard.host_reservations.no_confirmed_reservations')
    when 'archived'
      t('dashboard.host_reservations.no_archived_reservations')
    end
  end

  def dashboard_menu_item(key = nil, path = nil, options = {})
    if !options[:not_hideable]
      return nil if HiddenUiControls.find(key).hidden?
    end
    controller = params[:controller].split('/').last
    key_controller = key.split('/').last
    options.reverse_merge!(link_text: t("dashboard.nav.#{key_controller}"), active: nil)
    content_tag :li, class: (options[:active] || (controller == key_controller && options[:active] == nil)) ? 'active' : '' do
      link_to options[:link_text], path
    end
  end

  def mobile_menu_caption
    controller = params[:controller]
    action = params[:action]

    caption = t("dashboard.nav.#{controller.split('/').last}")
    caption = t('dashboard.nav.edit') if controller.include?('registration') && action.include?('edit')
    caption = t('dashboard.nav.social_accounts') if controller.include?('registration') && action.include?('social_accounts')
    caption = t('dashboard.nav.menu') if caption.include?('translation missing')
    caption
  end

  def booking_types_active_toggle(transactable, booking_type, content = false)
    if transactable.transactable_type.booking_choices.size == 1
      'active' if booking_type == transactable.transactable_type.booking_choices.first
    else
      'active' if transactable.booking_type == booking_type \
        || (content && transactable.booking_type.in?(%w(overnight recurring)) && booking_type == 'regular')
    end
  end
end
