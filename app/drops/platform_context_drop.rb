class PlatformContextDrop < BaseDrop

  attr_reader :platform_context_decorator

  delegate :name, :bookable_noun, :pages, :platform_context, :blog_url, :twitter_url, :lessor, :lessors, :lessee, :lessees, :searcher_type,
    :facebook_url, :address, :phone_number, :gplus_url, :site_name, :support_url, :support_email, :logo_image, :tagline, :search_field_placeholder, :homepage_content,
    :is_company_theme?, :call_to_action, :latest_products, :buyable?, :bookable?, :transactable_types, :product_types, :bookable_nouns, :bookable_nouns_plural, to: :platform_context_decorator


  def initialize(platform_context_decorator)
    @platform_context_decorator = platform_context_decorator
  end

  def bookable_noun_plural
    @platform_context_decorator.bookable_noun.pluralize
  end

  def logo_url
    @platform_context_decorator.logo_image.url || image_url("platform_home/logo-01-dark.png").to_s
  end

  def checked_badge_url
    image_url("themes/buy_sell/check.png")
  end

  def root_path
    routes.root_path
  end

  def host
    "http://#{platform_context_decorator.host}"
  end

  def asset_host
    Rails.application.config.action_controller.asset_host || host
  end

  def color_black
    theme_color('black')
  end

  def color_blue
    theme_color('blue')
  end

  def all_transactables
    transactable_types.services + product_types
  end

  def multiple_transactable_types?
    all_transactables.size > 1
  end

  def unsubscribe_url
    urlify(routes.edit_dashboard_notification_preferences_path)
  end

  def display_date_pickers?
    @platform_context_decorator.instance.date_pickers
  end

  def tt_select_type
    @platform_context_decorator.instance.tt_select_type
  end

  private

  def theme_color(color)
    @platform_context_decorator.theme.hex_color(color).presence || Theme.hexify(Theme.default_value_for_color(color))
  end

end
