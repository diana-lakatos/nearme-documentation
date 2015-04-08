class PlatformContextDrop < BaseDrop

  attr_reader :platform_context_decorator

  delegate :name, :bookable_noun, :pages, :platform_context, :blog_url, :twitter_url, :lessor, :lessors, :lessee, :lessees, :searcher_type, :search_by_keyword_placeholder, :fulltext_search?,
    :facebook_url, :address, :phone_number, :gplus_url, :site_name, :support_url, :support_email, :logo_image, :tagline, :search_field_placeholder, :homepage_content, :fulltext_geo_search?,
    :is_company_theme?, :call_to_action, :latest_products, :buyable?, :bookable?, :transactable_types, :product_types, :bookable_nouns, :bookable_nouns_plural, :search_input_name, to: :platform_context_decorator


  def initialize(platform_context_decorator)
    @platform_context_decorator = platform_context_decorator
    @instance = platform_context_decorator.instance
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

  def all_categories
    transactable_types.services.map{ |t| t.categories.roots }.flatten
  end

  def multiple_transactable_types?
    all_transactables.size > 1
  end

  def unsubscribe_url
    urlify(routes.edit_dashboard_notification_preferences_path)
  end

  def display_date_pickers?
    @instance.date_pickers
  end

  def tt_select_type
    @instance.tt_select_type
  end

  def calculate_elements
    sum = 2 #search button
    sum += 4 if display_date_pickers?
    sum += 2 if multiple_transactable_types? && tt_select_type != 'radio'
    sum += 3 if category_search?
    input_size = 12 - sum #span12
    input_size /= 2 if fulltext_geo_search? #two input fields
    container = input_size == 2 ? "span12" : "span10 offset1"
    [container, input_size]
  end

  def calculate_container
    calculate_elements[0]
  end

  def calculate_input_size
    "span#{calculate_elements[1]}"
  end

  def fulltext_category_search?
    @instance.searcher_type == 'fulltext_category'
  end

  def geo_category_search?
    @instance.searcher_type == 'geo_category'
  end

  def category_search?
    fulltext_category_search? || geo_category_search?
  end

  private

  def theme_color(color)
    @platform_context_decorator.theme.hex_color(color).presence || Theme.hexify(Theme.default_value_for_color(color))
  end

end
