# frozen_string_literal: true
class PlatformContextDrop < BaseDrop
  # @return [PlatformContextDecorator]
  attr_reader :platform_context_decorator

  # @!method name
  #   Name of the marketplace
  #   @return (see Instance#name)
  # @!method bookable_noun
  #   @return (see Instance#bookable_noun)
  #   @deprecated Use {TransactableTypeDrop#bookable_noun} instead
  # @!method pages
  #   @return [Array<PageDrop>] CMS pages for the current theme
  # @!method blog_url
  #   Blog URL for the current theme
  #   @return (see Theme#blog_url)
  # @!method facebook_url
  #   Facebook URL for the current theme
  #   @return (see Theme#facebook_url)
  # @!method twitter_url
  #   Twitter URL for the current theme
  #   @return (see Theme#twitter_url)
  # @!method gplus_url
  #   Google Plus URL for the current theme
  #   @return (see Theme#gplus_url)
  # @!method instagram_url
  #   Instagram URL for the current theme
  #   @return (see Theme#instagram_url)
  # @!method youtube_url
  #   Youtube URL for the current theme
  #   @return (see Theme#youtube_url)
  # @!method rss_url
  #   RSS URL for the current theme
  #   @return (see Theme#rss_url)
  # @!method linkedin_url
  #   LinkedIn URL for the current theme
  #   @return (see Theme#linkedin_url)
  # @!method lessor
  #   Lessor name for this marketplace
  #   @return (see Instance#lessor)
  #   @deprecated use {TransactableTypeDrop#lessor} instead
  # @!method lessors
  #   @return [String] plural of {Instance#lessor}
  #   @deprecated use {TransactableTypeDrop#lessor} instead
  # @!method lessee
  #   Lessee name for this marketplace
  #   @return (see Instance#lessee)
  #   @deprecated use {TransactableTypeDrop#lessee} instead
  # @!method lessees
  #   @return [String] plural of {Instance#lessee}
  #   @deprecated use {TransactableTypeDrop#lessee} instead
  # @!method search_by_keyword_placeholder
  #   @return [String] placeholder for the search box on the homepage
  # @!method address
  #   Address as set for the current theme
  #   @return (see Theme#address)
  # @!method phone_number
  #   Phone number as set for the current theme
  #   @return (see Theme#phone_number)
  # @!method phone_number_noformat
  #   @return [String] phone number with all non-digit characters stripped
  # @!method site_name
  #   Site name as set for the current theme
  #   @return (see Theme#site_name)
  # @!method support_url
  #   Support URL as set for the current theme
  #   @return (see Theme#support_url)
  # @!method support_email
  #   Support email as set for the current theme
  #   @return (see Theme#support_email)
  # @!method logo_image
  #   @return [ThemeImageUploader] uploader object for the logo image
  # @!method hero_image
  #   @return [ThemeImageUploader] uploader object for the hero image
  # @!method tagline
  #   Tagline as set in the current theme
  #   @return (see Theme#tagline)
  # @!method is_company_theme?
  #   @return [Boolean] whether the owner object of the theme is a {CompanyDrop} object
  # @!method call_to_action
  #   Call to action text as set for the current theme
  #   @return (see Theme#call_to_action)
  # @!method bookable?
  #   @return [Boolean] whether bookable/purchaseable {TransactableTypeDrop} objects have been defined for this instance
  # @!method transactable_types
  #   @return [Array<TransactableTypeDrop>] TransactableType objects defined for this instance
  # @!method action_rfq?
  #   @return [Boolean] whether any of the action types have request for quotation enabled
  # @!method bookable_nouns
  #   @return [String] sentence containing all the bookable nouns available on this platform
  # @!method bookable_nouns_plural
  #   @return [String] sentence containing all the bookable nouns (pluralized) available on this platform
  # @!method facebook_key
  #   @return [String] Facebook consumer key for this instance
  # @!method service_types
  #   @return [Array<TransactableTypeDrop>] array of transactable types for this marketplace;
  #     added for reverse compatibility
  # @!method wish_lists_icon_set
  #   What set of icons to use for wishlists
  #   @return (see Instance#wish_lists_icon_set)
  # @!method seller_attachments_enabled?
  #   @return [Boolean] whether seller attachments are enabled for this marketplace
  # @!method wish_lists_enabled?
  #   @return [Boolean] whether wish lists have been enabled for the marketplace
  # @!method webhook_token
  #   @return [String] Webhook token as a string for this marketplace
  # @!method instance
  #   @return [InstanceDrop] instance object, the root object defining a marketplace
  # @!method enable_geo_localization
  #   Whether geo localization is enabled for this instance
  #   @return (see Instance#enable_geo_localization)
  # @!method split_registration?
  #   Whether split registration is enabled for this instance allowing separate
  #     profiles for buyers/sellers
  #   @return (see Instance#split_registration)
  # @!method enquirer_blogs_enabled
  #   Whether blogs for enquirers (buyers) are enabled for this instance
  #   @return (see Instance#enquirer_blogs_enabled)
  # @!method lister_blogs_enabled
  #   Whether blogs for listers (sellers) are enabled for this instance
  #   @return (see Instance#lister_blogs_enabled)
  # @!method debugging_mode_for_admins?
  #   @return [Boolean] whether debugging mode for admins is currently enabled
  # @!method projectable?
  #   @return [Boolean] whether there are Projects created for this marketplace
  # @!method transactable_types_ordered
  #   @return [Array<TransactableTypeDrop>] array of TransactableTypeDrop for this marketplace ordered by their names
  # @!method transactable_types_as_hash
  #   @return [Hash{String => TransactableTypeDrop}] hash where the keys are the TransactableType names
  #     and the values are TransactableTypeDrop objects for this marketplace
  # @todo Remove #projectable from drop when ProjectType will be finally removed
  delegate :name, :bookable_noun, :pages, :blog_url, :facebook_url, :twitter_url, :gplus_url,
           :instagram_url, :youtube_url, :rss_url, :linkedin_url, :lessor, :lessors,
           :lessee, :lessees, :search_by_keyword_placeholder, :address, :phone_number, :phone_number_noformat,
           :site_name, :support_url, :support_email, :logo_image, :hero_image, :tagline,
           :is_company_theme?, :call_to_action, :projectable?, :bookable?, :transactable_types, :action_rfq?,
           :bookable_nouns, :bookable_nouns_plural, :facebook_key, :service_types,
           :wish_lists_icon_set, :seller_attachments_enabled?, :wish_lists_enabled?,
           :active_rating_systems_present?, :webhook_token, :instance, :enable_geo_localization, :split_registration?,
           :enquirer_blogs_enabled, :lister_blogs_enabled, :debugging_mode_for_admins?,
           :transactable_types_ordered, :transactable_types_as_hash, to: :platform_context_decorator

  def initialize(platform_context_decorator)
    @platform_context_decorator = platform_context_decorator
    @instance = platform_context_decorator.instance
  end

  # @return [String] name of the bookable item for this marketplace (plural) as a string
  # @deprecated use {TransactableTypeDrop#bookable_noun_plural}
  # @ todo -- remove per depracation
  def bookable_noun_plural
    @platform_context_decorator.bookable_noun.pluralize
  end

  # @return [String] url to the logo image as set in the current theme
  # @todo depracate per DIY
  def logo_url
    @platform_context_decorator.logo_image.url
  end

  # @return [String] url to the hero image as set in the current theme or a default image
  #   if not set
  # @todo depracate per DIY
  def hero_url
    @platform_context_decorator.hero_image.url.presence || image_url('community/hero-a-bg-a.jpg').to_s
  end

  # @return [String] url to the "checked badge" image (a predefined image)
  # @todo depracate per DIY
  def checked_badge_url
    image_url('themes/buy_sell/check.png')
  end

  # @!method root_path
  #   @return [String] root path for this marketplace
  delegate :root_path, to: :routes

  # @return [String] full url to the root of the marketplace
  def host
    "https://#{platform_context_decorator.host}"
  end

  # @return [String] full url to the root of the server hosting the assets (images, javascripts, stylesheets etc.)
  def asset_host
    Rails.application.config.action_controller.asset_host || host
  end

  # @return [String] hex value (as string) for the color black as set for this marketplace, or the default
  # @todo -- depracate per DIY
  def color_black
    theme_color('black')
  end

  # @return [String] hex value (as string) for the color blue as set for this marketplace, or the default
  # @todo -- depracate per DIY
  def color_blue
    theme_color('blue')
  end

  # @return [Boolean] whether this marketplace has multiple service types defined
  def multiple_transactable_types?
    transactable_types.searchable.many?
  end

  # @return [String] url for editing the notification preferences
  # @todo depracate per DIY
  def unsubscribe_url
    urlify(routes.edit_dashboard_notification_preferences_path)
  end

  # @return [String] the type of select for this marketplace to be used when
  #   multiple service types are defined (e.g. radio, dropdown etc.)
  # @todo depracate per DIY
  def tt_select_type
    @instance.tt_select_type
  end

  # @return [Boolean] whether to enable the languages selector in the footer for
  #   this marketplace
  # @todo depracate per DIY
  def is_footer_languages_select?
    @instance.enable_language_selector?
  end

  # @return [String] URL to the project wizard path
  # @deprecated Should be removed when project types are removed
  # @todo Remove when project types are removed -- arent they removed already? (23.11.2016)
  # @todo -- depracate on favor of filter
  def project_space_wizard_path
    @project_type ||= ProjectType.first
    routes.new_project_type_project_wizard_path(@project_type) if @project_type
  end

  # @return [String] url to the spam reports area in admin for this marketplace
  # @todo -- depracate on favor of filter
  def spam_reports_path
    urlify(routes.instance_admin_projects_spam_reports_path)
  end

  # @return [String] returns the path to the admin area for this marketplace
  # @todo -- depracate on favor of filter
  def instance_admin_path
    urlify(routes.instance_admin_path)
  end

  # @return [Boolean] whether there are active rating systems (enabled) for this
  #   marketplace
  # @todo -- investigate if its the best place for it - i assume rating system will grow so maybe separate drop would be appropriate
  def active_rating_systems_present?
    RatingSystem.active.any?
  end

  # @return [Boolean] whether split registration is enabled for this marketplace
  #   allowing separate profiles for buyers and sellers
  # @todo -- depracate per DIY
  def split_registration?
    @instance.split_registration?
  end

  # The method sets the variable @render_content_outside_container to true to affect subsequent rendering
  # (render the contents of the page outside the main container)
  # @return [String] blank string
  # @todo -- depracate per DIY
  def set_render_content_outside_container
    @context.registers[:action_view].instance_variable_set('@render_content_outside_container', true)
    '' # return empty string so nothing is displayed
  end

  # The method sets the variable @theme_name to a blank string affecting subsequent rendering
  # (theme name is used as a class for the body element)
  # @return [String] blank string
  # @todo -- depracate per DIY
  def set_blank_theme_name
    @context.registers[:action_view].instance_variable_set('@theme_name', '')
    '' # return empty string so nothing is displayed
  end

  # @return [String] current Rails environment (development/staging/production)
  def rails_env
    Rails.env
  end

  # @return [Array<UserBlogPostDrop>] array of highlighted user blog posts
  # @todo -- investigate if needed. if yes, transform to filter to allow variable limit
  # @todo -- also it probably should be in BlogDrop or somewhere around that
  def highlighted_blog_posts
    # tmp solution until we have proper solution to fetch any data on any page
    @platform_context_decorator.instance.user_blog_posts.highlighted.by_date.limit(3)
  end

  private

  # Helper method
  # @return [String] hex value for the color received as parameter as set in the current
  #   theme, or the default value for this color
  # @todo -- depracate per DIY
  def theme_color(color)
    @platform_context_decorator.theme.hex_color(color).presence || Theme.hexify(Theme.default_value_for_color(color))
  end
end
