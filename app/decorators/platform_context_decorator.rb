class PlatformContextDecorator

  delegate :white_label_company, :instance, :instance_type, :theme, :partner, :domain, :white_label_company_user?,
    :platform_context_detail, :secured_constraint, :latest_products, to: :platform_context

  delegate :tagline, :support_url, :blog_url, :twitter_url, :twitter_handle, :facebook_url, :gplus_url, :address,
    :phone_number, :site_name, :description, :support_email, :compiled_stylesheet, :compiled_dashboard_stylesheet, :meta_title, :pages, :logo_image,
    :favicon_image, :icon_image, :icon_retina_image, :homepage_content, :call_to_action, :is_company_theme?, :content_holders, to: :theme

  delegate :bookable_noun, :lessor, :lessee, :name, :buyable?, :bookable?, :transactable_types, :product_types, to: :instance

  liquid_methods :lessors

  def initialize(platform_context)
    @platform_context = platform_context
  end

  def compiled_stylesheet_url
    compiled_stylesheet.present? ? compiled_stylesheet.url : nil
  end

  def compiled_dashboard_stylesheet_url
    compiled_dashboard_stylesheet.present? ? compiled_dashboard_stylesheet.url : nil
  end

  def single_type?
    [self.transactable_types.services.count, self.product_types.count].sum  == 1
  end

  def to_liquid
    @platform_context_drop ||= PlatformContextDrop.new(self)
  end

  def lessors
    lessor.pluralize
  end

  def lessees
    lessee.pluralize
  end

  def host
    domain.name
  end

  def build_url_for_path(path)
    raise "Expected relative path, got #{path}" unless path[0] == '/'
    "http://#{host}#{path}"
  end

  def support_email_for(error_code)
    support_email_splited = self.support_email.split('@')
    support_email_splited.join("+#{error_code}@")
  end

  def contact_email
    @platform_context.theme.contact_email_with_fallback
  end

  def search_field_placeholder
    case instance.buyable?
    when false
      instance.searcher_type == 'fulltext' ? I18n.t('homepage.search_field_placeholder.full_text') : I18n.t('homepage.search_field_placeholder.location')
    when true
      I18n.t 'homepage.search_field_placeholder.search'
    end
  end

  def search_by_keyword_placeholder
    I18n.t('homepage.search_field_placeholder.full_text')
  end

  def searcher_type
    instance.searcher_type
  end

  def fulltext_search?
    searcher_type == 'fulltext'
  end

  def fulltext_geo_search?
    searcher_type == "fulltext_geo"
  end

  def footer_cache_key
    "footer_#{platform_context_detail_key}_#{normalized_footer_cache_timestamp}"
  end

  def platform_context_detail_key
    @platform_context_detail_key = "#{platform_context_detail.class.to_s.downcase}_#{platform_context_detail.id}"
  end

  def normalized_footer_cache_timestamp
    instance_view_footer_timestamp = @platform_context.instance.instance_views.find_by(:path => 'layouts/theme_footer').try(:updated_at)
    normalize_timestamp([pages.maximum(:updated_at), theme.updated_at, instance_view_footer_timestamp].compact.max)
  end

  def normalize_timestamp(timestamp)
    timestamp.try(:utc).try(:to_s, :number)
  end

  def stripe_public_key
    @platform_context.instance.instance_payment_gateways.get_settings_for(:stripe, :public_key)
  end

  def supported_payout_via_ach?
    Billing::Gateway::Processor::Outgoing::ProcessorFactory.supported_payout_via_ach?(self.instance)
  end

  def map_view
    if ['mixed', 'listing_mixed'].include?(platform_context.instance.default_search_view)
      platform_context.instance.default_search_view
    else
      'mixed'
    end
  end

  def bookable_nouns
    @bookable_nouns ||= transactable_types.map { |tt| tt.bookable_noun.presence || tt.name }.to_sentence(last_word_connector: I18n.t('general.or_spaced'))
  end

  def bookable_nouns_plural
    @bookable_nouns_plural ||= transactable_types.map { |tt| (tt.bookable_noun.presence || tt.name).pluralize }.to_sentence(last_word_connector: I18n.t('general.or_spaced'))
  end

  def display_taxonomy_tree?
    platform_context.instance.taxonomy_tree
  end

  def search_input_name
    fulltext_search? ? "query" : "loc"
  end

  private

  def platform_context
    @platform_context
  end

end
