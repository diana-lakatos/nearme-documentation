# frozen_string_literal: true
module DashboardHelper
  def in_new_listing?
    (params[:action] == 'new' || params[:action] == 'edit') && params[:controller].include?('listings') && params[:id].blank?
  end

  def in_new_or_edit?
    %w(new create edit update).include?(params[:action])
  end

  def analytics_options
    if TransactableType.exists?(skip_location: false)
      [[t('dashboard.analytics.expenses'), 'expenses'], [t('dashboard.analytics.revenue'), 'revenue'], [t('dashboard.analytics.bookings'), 'orders']]
    else
      [[t('dashboard.analytics.expenses'), 'expenses'], [t('dashboard.analytics.revenue'), 'revenue'], [t('dashboard.analytics.bookings'), 'orders'], [t('dashboard.analytics.location_views'), 'location_views']]
    end
  end

  def analytics_options_for_select
    options_for_select(analytics_options, @analytics_mode)
  end

  def analytics_active_nav_tab
    tab = analytics_options.find { |t| t[1] == @analytics_mode }
    if tab.blank?
      analytics_options.first[0]
    else
      tab[0]
    end
  end

  def no_purchases_yet_text
    t('dashboard.analytics.no_reservations_yet')
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

    classes << 'active' if @location && @location == location

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
    return nil unless options[:not_hideable] || !HiddenUiControls.find(key).hidden?
    controller = params[:controller].split('/').last
    key_controller = key.split('/').last
    options.reverse_merge!(link_text: t("dashboard.nav.#{key_controller}"), active: nil)
    content_tag :li, class: options[:active] || (controller == key_controller && options[:active].nil?) ? 'active' : '' do
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

  def booking_types_active_toggle(transactable, action_type, _content = false)
    'active' if transactable.action_type.try(:transactable_type_action_type) == action_type
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

  def hint_button(hint_text, placement: 'right')
    content_tag :button, type: 'button', class: 'hint-toggler', data: { toggle: 'tooltip', placement: placement }, title: hint_text do |_variable|
      t :toggle_hint
    end
  end

  def translated_hint_button(hint_translation_path, placement: 'right')
    hint_button(t(hint_translation_path), placement: placement) if is_i18n_set?(hint_translation_path)
  end

  def dropdown_menu(label, options = nil, &block)
    toggler_id = 'dropdown-' + SecureRandom.hex(5)

    wrapper_class = 'dropdown'
    wrapper_class = wrapper_class + ' ' + options[:wrapper_class] if options[:wrapper_class]

    toggler_class = 'dropdown-toggle'
    toggler_class = toggler_class + ' ' + options[:toggler_class] if options[:toggler_class]

    wrapper_tag = options[:wrapper_tag] || :div

    toggler_label = label.to_s + ' ' + content_tag(:span, nil, class: 'caret')

    content_tag wrapper_tag, class: wrapper_class do
      output = content_tag :a, toggler_label.html_safe, href: '#', id: toggler_id, type: 'button', class: toggler_class, data: { toggle: 'dropdown' }, aria: { haspopup: 'true', expanded: 'false' }

      output += content_tag :ul, capture(&block), class: 'dropdown-menu', "aria-labelledby": toggler_id

      output
    end
  end

  def dashboard_simple_form_for(resource, options = {}, &block)
    options[:wrapper] = :dashboard_form
    options[:error_class] = :field_with_errors

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
    reservations_count = current_user.orders.reservations.not_archived.count
    out = t('dashboard.nav.user_reservations')
    out = "#{out} <span>#{reservations_count}</span>".html_safe if reservations_count > 0
    out
  end

  def dashboard_nav_host_reservations_label
    reservations_count = Controller::GuestList.new(current_user).filter('unconfirmed').reservations.size
    out = t('dashboard.nav.host_reservations')
    out = "#{out} <span>#{reservations_count}</span>".html_safe if reservations_count > 0
    out
  end

  def dashboard_transactable_photos_to_image_input_collection(photos)
    collection = []

    photos.each do |photo|
      item = {}
      item[:id] = photo.id
      item[:full_url] = photo.image_url
      item[:position] = photo.position
      item[:thumb_url] = photo.image_url(:space_listing)
      item[:caption] = photo.caption if photo.respond_to?(:caption)
      if photo.persisted?
        item[:edit_url] = edit_dashboard_photo_path(photo)
        item[:delete_url] = destroy_space_wizard_photo_path(photo)
      end
      collection << item
    end

    collection
  end

  def dashboard_panel_multi_tabs(items)
    return if items.count < 2

    out = ActiveSupport::SafeBuffer.new
    active = items.find { |item| item[:active] }

    if active.nil?
      items.first[:active] = true
      active = items.first
    end

    out << content_tag(:nav, class: 'panel-nav-mobile') do
      dropdown_menu active[:name], wrapper_class: 'links' do
        links = ActiveSupport::SafeBuffer.new
        items.each do |item|
          links << content_tag(:li, class: (item[:active] ? 'active' : nil)) do
            link_to item[:name], item[:url]
          end
        end
        links
      end
    end

    out << content_tag(:nav, class: 'panel-nav') do
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
    override = PlatformContext.current.theme.photo_upload_versions.where(photo_uploader: object.class).first

    # This assumes all versions have the same aspect ratio. Good enough for now
    return override.width.to_f / override.height.to_f if override

    unless defined?(object.class::ASPECT_RATIO)
      return object.model.send("#{object.mounted_as}_dimensions")[:width].to_f / object.model.send("#{object.mounted_as}_dimensions")[:height].to_f
    end

    return object.class::ASPECT_RATIO_PROJECT if object.model.try(:owner_type) == 'Project'

    object.class::ASPECT_RATIO
  end
end
