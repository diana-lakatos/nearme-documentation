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
    periods.map(&:date).map { |date| date.to_s(:db) }
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

  def dashboard_menu_item(key = nil, path = nil, options = {})
    return nil if HiddenUiControls.find(key).hidden?
    options.reverse_merge!(link_text: nil, active: nil)
    controller = params[:controller].split('/').last
    key_controller = key.split('/').last
    content_tag :li, class: (options[:active] || (controller == key_controller && options[:active] == nil)) ? 'active' : '' do
      link_to options[:link_text] || t("dashboard.nav.#{key_controller}"), path
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
    'active' if transactable.booking_type == booking_type \
             || (content && transactable.booking_type.in?(%w(overnight recurring)) && booking_type == 'regular')
  end
end
