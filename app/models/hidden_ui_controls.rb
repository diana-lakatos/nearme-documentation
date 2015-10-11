class HiddenUiControls

  class KeyNotFound < ActiveRecord::RecordNotFound;
  end

  BUY_SELL_KEYS = [
      'dashboard/orders',
      'dashboard/products',
      'dashboard/orders_received',
      'registrations/show#products',
      'main_menu/my_orders',
      'main_menu/cart',
      'dashboard/products/bulk_upload',
      'dashboard/products/search'
  ]

  PROJECT_KEYS = [
    'dashboard/projects'
  ]

  SERVICE_KEYS = [
      'dashboard/user_reservations',
      'dashboard/user_recurring_bookings',
      'dashboard/transactables',
      'dashboard/host_reservations',
      'dashboard/host_recurring_bookings',
      'registrations/show#services',
      'main_menu/my_bookings',
      'main_menu/my_subscriptions',
      'dashboard/transactables/bulk_upload',
      'dashboard/transactables/search'
  ]

  COMMON_KEYS = [
      'dashboard/user_messages',
      'dashboard/companies',
      'dashboard/payouts',
      'dashboard/transfers',
      'dashboard/analytics',
      'dashboard/users',
      'dashboard/waiver_agreement_templates',
      'dashboard/white_labels',
      'dashboard/tickets',
      'dashboard/support/tickets',
      'registrations/edit',
      'dashboard/notification_preferences',
      'registrations/social_accounts',
      'dashboard/blog',
      'registrations/show#reviews',
      'registrations/show#blog_posts',
      'dashboard/reviews',
      'dashboard/wish_list_items',
      'main_menu/manage_items',
      'main_menu/cta',
      'main_menu/rfq',
      'main_menu/manage_blog',
      'main_menu/wish_list',
      'main_menu/account',
      'main_menu/view_profile',
      'main_menu/messages',
      'dashboard/payment_documents/sent_to_me',
      'dashboard/saved_searches'
  ]

  def self.find(key)
    index = all_keys.find_index(key)
    index ? to_obj(all_keys[index]) : raise(KeyNotFound, "Unable to find key #{key}")
  end

  def self.all(type=:auto)
    selected_keys = keys(type)
    selected_keys.map { |key| to_obj(key) }
  end

  def self.keys(type=:auto)
    case type
    when :auto
      instance = PlatformContext.current.instance
      if instance.buyable? && instance.bookable?
        all_keys
      elsif instance.buyable?
        buy_sell_keys
      elsif instance.bookable?
        service_keys
      end
    when :buy_sell
      buy_sell_keys
    when :service
      service_keys
    else
      all_keys
    end
  end

  private

  def self.is_key_hidden?(key)
    PlatformContext.current.instance.hidden_ui_controls.key? key
  end

  def self.to_obj(key)
    OpenStruct.new(name: key, tab?: is_key_tab?(key), menu?: is_key_menu?(key), hidden?: is_key_hidden?(key),
                   visible?: is_key_visible?(key), type: key_type(key), display_name: key_display_name(key),
                   display_type: key_display_type(key))
  end

  def self.all_keys
    BUY_SELL_KEYS + SERVICE_KEYS + PROJECT_KEYS + COMMON_KEYS
  end

  def self.buy_sell_keys
    BUY_SELL_KEYS + COMMON_KEYS
  end

  def self.projects_keys
    PROJECT_KEYS
  end

  def self.service_keys
    SERVICE_KEYS + COMMON_KEYS
  end

  def self.key_display_name(key)
    t_key = "hidden_items.#{key.gsub('/', '.').gsub('#', '.').gsub('-', '_')}"
    translation = I18n.t t_key
    return translation unless translation.include?('translation missing')

    name = key.split('/').map(&:capitalize).map(&:humanize).join(' > ')
    tab_name = (name.include?('#') ? name.match(/#(.+)/)[1] : '').capitalize
    tab_name = " > #{tab_name}" unless tab_name.empty?
    "#{name.gsub(/#(.+)/, '')}#{tab_name}"
  end

  def self.is_key_tab?(key)
    key.include? '#'
  end

  def self.is_key_menu?(key)
    key.include? 'menu'
  end

  def self.is_key_visible?(key)
    !is_key_hidden?(key)
  end

  def self.key_type(key)
    if is_key_tab?(key)
      :tab
    elsif is_key_menu?(key)
      :menu
    else
      :page
    end
  end

  def self.key_display_type(key)
    case key_type(key)
    when :tab
      'Tab'
    when :menu
      'Menu'
    else
      'Page'
    end
  end
end
