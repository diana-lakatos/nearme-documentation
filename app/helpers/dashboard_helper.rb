module DashboardHelper

  def in_new_listing?
    (params[:action] == 'new' || params[:action] == 'edit') && params[:controller].include?('listings') && params[:id].blank?
  end

  def in_new_or_edit?
    ['new', 'create', 'edit', 'update'].include?(params[:action])
  end

  def analytics_options
    if PlatformContext.current.instance.buyable?
      [[t('dashboard.analytics.revenue'), 'revenue'], [t('dashboard.analytics.orders'), 'orders'], [t('dashboard.analytics.product_views'), 'product_views']]
    else
      [[t('dashboard.analytics.revenue'), 'revenue'], [t('dashboard.analytics.bookings'), 'bookings'], [t('dashboard.analytics.location_views'), 'location_views']]
    end
  end

  def analytics_options_for_select
    options_for_select(analytics_options, @analytics_mode)
  end

  def analytics_nav_tabs
    out = ActiveSupport::SafeBuffer.new

    analytics_options.each do |tab|
      out << content_tag(:li, class: (tab[1] == @analytics_mode ? 'active' : '')) do
        link_to tab[0], "?analytics_mode=#{tab[1]}"
      end
    end

    out
  end

  def analytics_active_nav_tab
    tab = analytics_options.find { |tab| tab[1] == @analytics_mode }
    if tab.blank?
      tab[0]
    end

    analytics_options.first[0]

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
    when 'overdue'
      t('dashboard.host_reservations.no_overdue_reservations')
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
    booking_type = Array.wrap(booking_type)
    if transactable.transactable_type.booking_choices.size == 1
      'active' if booking_type.include? transactable.transactable_type.booking_choices.first
    else
      'active' if booking_type.include? transactable.booking_type \
        || (content && transactable.booking_type.in?(%w(overnight recurring)) && booking_type.include?('regular'))
    end
  end

  def currency_options
    currencies = ::Money::Currency.table.map do |code, details|
      iso = details[:iso_code]
      [iso, "#{details[:name]} (#{iso})"]
    end
    options_from_collection_for_select(currencies, :first, :last, Spree::Config[:currency])
  end

  # New Ux UI

  def new_listing_step(index, current, label)
    wrapper_class = index == current ? 'current' : nil
    content_tag :li, class: wrapper_class do
      if current > index
        link_to label, listing_new_path(step: index)
      else
        content_tag :span, label
      end
    end
  end

  def hint_button(hint_text, placement: "right")
    content_tag :button, type: "button", class: 'hint-toggler', data: { toggle: "tooltip", placement: placement }, title: hint_text do |variable|
      t :toggle_hint
    end
  end

  def dropdown_menu(label, options = nil, &block )
    toggler_id = 'dropdown-' + SecureRandom.hex(5)

    wrapper_class = 'dropdown'
    if options[:wrapper_class]
      wrapper_class = wrapper_class + ' ' + options[:wrapper_class]
    end

    toggler_class = 'dropdown-toggle'
    if options[:toggler_class]
      toggler_class = toggler_class + ' ' + options[:toggler_class]
    end

    wrapper_tag = options[:wrapper_tag] || :div

    toggler_label = label + ' ' + content_tag(:span, nil, class: 'caret')

    content_tag wrapper_tag, class: wrapper_class do
      output = content_tag :a, toggler_label.html_safe, href: '#', id: toggler_id, type: "button", class: toggler_class, data: {toggle: "dropdown"}, aria: { haspopup: "true", expanded: "false" }

      output += content_tag :ul, capture(&block), class: 'dropdown-menu', :"aria-labelledby" => toggler_id

      output
    end
  end

  def dashboard_simple_form_for(resource, options = {}, &block)
    options[:wrapper] = :dashboard_form


    options[:wrapper_mappings] = {
      check_boxes: :dashboard_radio_and_checkboxes,
      radio_buttons: :dashboard_radio_and_checkboxes,
      file: :dashboard_file_input,
      boolean: :dashboard_boolean,
      switch: :dashboard_switch,
      inline_form: :dashboard_inline_form,
      limited_string: :dashboard_form,
      limited_text: :dashboard_form,
      tel: :dashboard_addon,
      price: :dashboard_form
    }
    simple_form_for(resource, options, &block)
  end

  def navigation_visible?
    cookies[:navigation_visible] == 'true'
  end

  def dashboard_nav_user_messages_label
    t('dashboard.nav.user_messages_count', count: current_user.unread_user_message_threads_count_for(platform_context.instance)).html_safe
  end

  def dashboard_nav_user_reservations_label
    reservations_count = current_user.reservations.no_recurring.not_archived.count
    reservations_count > 0 ? t('dashboard.nav.user_reservations_count_html', count: reservations_count) : t('dashboard.nav.user_reservations')
  end

  def dashboard_transactable_photos_to_image_input_collection(photos)
    collection = Array.new

    photos.each do |photo|
      item = Hash.new
      item[:id] = photo.id
      item[:full_url] = photo.image_url
      item[:position] = photo.position
      item[:thumb_url] = photo.image_url(:space_listing)
      item[:edit_url] = edit_dashboard_photo_path(photo)
      item[:delete_url] = destroy_space_wizard_photo_path(photo)
      item[:caption] = photo.caption if photo.respond_to?(:caption)
      collection << item
    end

    return collection
  end

  def dashboard_product_images_to_image_input_collection(images)
    collection = Array.new

    images.each do |image|
      item = Hash.new
      item[:id] = image.id
      item[:full_url] = image.image_url
      item[:position] = image.position
      item[:thumb_url] = image.image_url(:space_listing)
      item[:edit_url] = edit_dashboard_image_path(image)
      item[:delete_url] = dashboard_image_path(image)
      item[:caption] = image.caption if image.respond_to?(:caption)
      collection << item
    end

    return collection
  end

  def dashboard_panel_multi_tabs(items)
    out = ActiveSupport::SafeBuffer.new
    active = items.select {|item| item[:active] }.first

    out << content_tag(:nav, class: 'panel-nav-mobile visible-sm visible-xs') do
      dropdown_menu active[:name], { wrapper_class: 'links'} do
        links = ActiveSupport::SafeBuffer.new
        items.each do |item|
          links << content_tag(:li, class: (item[:active] ? 'active' : nil)) do
            link_to item[:name], item[:url]
          end
        end
        links
      end
    end

    out << content_tag(:nav, class: 'panel-nav hidden-sm hidden-xs') do
      content_tag(:ul, class: 'tabs pull-left') do
        links = ActiveSupport::SafeBuffer.new
        items.each do |item|
          links << content_tag(:li, class: (item[:active] ? 'active' : nil)) do
            link_to item[:name], item[:url]
          end
        end
        links
      end
    end

    out
  end

  def object_aspect_ratio(object)
    unless defined?(object.class::ASPECT_RATIO)
      return object.model.send("#{object.mounted_as}_dimensions")[:width].to_f / object.model.send("#{object.mounted_as}_dimensions")[:height].to_f
    end

    return object.class::ASPECT_RATIO_PROJECT if object.model.try(:owner_type) == 'Project'

    object.class::ASPECT_RATIO
  end
end
