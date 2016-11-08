# frozen_string_literal: true
class PlatformContextDrop < BaseDrop
  attr_reader :platform_context_decorator

  # name
  #   name of the marketplace
  # bookable_noun
  #   name of representing the bookable object transactable on the marketplace as a string
  # pages
  #   array of pages created for this marketplace by the marketplace admin
  # lessor
  #   name of the person which offers the service
  # lessors
  #   pluralized name of the person which offers the service
  # lessee
  #   name of the person which uses (purchases) the service
  # lessees
  #   pluralized name of the person which uses (purchases) the service
  # searcher_type
  #   type of search for this marketplace as set by the marketplace admin from the marketplace administration interface
  # search_by_keyword_placeholder
  #   placeholder text for searching by keyword; usually is "Search by keyword" unless a translation key has been added for this string by the marketplace admin
  # address
  #   address of the company operating the marketplace as a string
  # phone_number
  #   phone_number of the company operating the marketplace as a string
  # blog_url
  #   url to the blog for this marketplace
  # facebook_url
  #   url for the Facebook page of this marketplace
  # twitter_url
  #   the twitter address for this marketplace
  # gplus_url
  #   url to the Google Plus page of the marketplace
  # instagram_url
  #   url for the Instagram page of this marketplace
  # youtube_url
  #   url for the Youtube page of this marketplace
  # rss_url
  #   url for the RSS page of this marketplace
  # site_name
  #   name of the marketplace
  # support_url
  #   url (or mailto: link) to the support page for this marketplace
  # support_email
  #   email address of the support department of this marketplace
  # logo_image
  #   logo image object containing the logo image for this marketplace
  #   logo_image.url returns the url of this logo_image
  # hero_image
  #   logo image object containing the logo image for this marketplace
  #   hero_image.url returns the url of this hero_image
  # tagline
  #   tagline for this marketplace as string
  # fulltext_geo_search?
  #   returns true if searcher_type for the marketplace is "fulltext_geo"
  # is_company_theme?
  #   returns true if the theme belongs to a company
  # call_to_action
  #   call to action text as set for this theme
  # bookable?
  #   returns true if the marketplace has any service types defined
  # transactable_types
  #   array of transactable_types (service types) for this marketplace
  # bookable_nouns
  #   text containing the bookable nouns as a sentence (e.g. "desk or table or room")
  # bookable_nouns_plural
  #   text containing the bookable nouns as a sentence (e.g. "desks or tables or rooms")
  # search_input_name
  #   HTML name of the input element to be used in search pages
  # facebook_key
  #   Key needed to display Like button in social button
  # wish_lists_icon_set
  #   Icon for favorite button
  # seller_attachments_enabled
  #   Whether seller attachments are enabled or not
  # wish_lists_enabled?
  #   Whether wish lists is enabled or not
  # active_rating_systems_present?
  #   Whether there is at least one active system
  # split_registration?
  #   Whether split registration is enabled for the instance
  # debugging_mode_for_admins?
  #   Whether debugging mode for admins is currently enabled
  delegate :name, :bookable_noun, :pages, :platform_context, :blog_url, :facebook_url, :twitter_url, :gplus_url,
           :instagram_url, :youtube_url, :rss_url, :linkedin_url, :lessor, :lessors,
           :lessee, :lessees, :search_by_keyword_placeholder, :address, :phone_number, :phone_number_noformat,
           :site_name, :support_url, :support_email, :logo_image, :hero_image, :tagline,
           :is_company_theme?, :call_to_action, :projectable?, :bookable?, :transactable_types, :action_rfq?,
           :bookable_nouns, :bookable_nouns_plural, :search_input_name, :facebook_key, :service_types,
           :wish_lists_icon_set, :seller_attachments_enabled?, :wish_lists_enabled?,
           :active_rating_systems_present?, :webhook_token, :instance, :enable_geo_localization, :split_registration?,
           :enquirer_blogs_enabled, :lister_blogs_enabled, :debugging_mode_for_admins?, to: :platform_context_decorator

  def initialize(platform_context_decorator)
    @platform_context_decorator = platform_context_decorator
    @instance = platform_context_decorator.instance
  end

  # name of the bookable item for this marketplace (plural) as a string
  def bookable_noun_plural
    @platform_context_decorator.bookable_noun.pluralize
  end

  # url to the logo image
  def logo_url
    @platform_context_decorator.logo_image.url
  end

  # url to the hero image
  def hero_url
    @platform_context_decorator.hero_image.url || image_url('intel/hero-a-bg-a.jpg').to_s
  end

  # url to the "checked badge" image
  def checked_badge_url
    image_url('themes/buy_sell/check.png')
  end

  # root path for this marketplace
  delegate :root_path, to: :routes

  # full url to the root of the marketplace
  def host
    "https://#{platform_context_decorator.host}"
  end

  # full url to the root of the server hosting the assets (images, javascripts, stylesheets etc.)
  def asset_host
    Rails.application.config.action_controller.asset_host || host
  end

  # hex value (as string) for the color black as set for this marketplace, or the default
  def color_black
    theme_color('black')
  end

  # hex value (as string) for the color blue as set for this marketplace, or the default
  def color_blue
    theme_color('blue')
  end

  # returns true if this marketplace has multiple service types defined
  def multiple_transactable_types?
    transactable_types.searchable.many?
  end

  # url for editing the notification preferences
  def unsubscribe_url
    urlify(routes.edit_dashboard_notification_preferences_path)
  end

  # returns the type of select for this marketplace to be used when
  # multiple service types are defined (e.g. radio, dropdown etc.)
  def tt_select_type
    @instance.tt_select_type
  end

  def is_footer_languages_select?
    @instance.enable_language_selector?
  end

  def project_space_wizard_path
    @project_type ||= ProjectType.first
    routes.new_project_type_project_wizard_path(@project_type) if @project_type
  end

  def spam_reports_path
    urlify(routes.instance_admin_projects_spam_reports_path)
  end

  def instance_admin_path
    urlify(routes.instance_admin_path)
  end

  def active_rating_systems_present?
    RatingSystem.active.any?
  end

  def split_registration?
    @instance.split_registration?
  end

  def rails_env
    Rails.env
  end

  def highlighted_blog_posts
    # tmp solution until we have proper solution to fetch any data on any page
    @platform_context_decorator.instance.user_blog_posts.highlighted.by_date.limit(3)
  end

  private

  def theme_color(color)
    @platform_context_decorator.theme.hex_color(color).presence || Theme.hexify(Theme.default_value_for_color(color))
  end
end
