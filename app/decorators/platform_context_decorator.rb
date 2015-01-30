class PlatformContextDecorator

  delegate :white_label_company, :instance, :instance_type, :theme, :partner, :domain, :white_label_company_user?,
    :platform_context_detail, :secured_constraint, :latest_products, to: :platform_context

  delegate :tagline, :support_url, :blog_url, :twitter_url, :twitter_handle, :facebook_url, :gplus_url, :address,
    :phone_number, :site_name, :description, :support_email, :compiled_stylesheet, :compiled_dashboard_stylesheet, :meta_title, :pages, :logo_image,
    :favicon_image, :icon_image, :icon_retina_image, :homepage_content, :call_to_action, :is_company_theme?, to: :theme

  delegate :bookable_noun, :lessor, :lessee, :name, :is_desksnearme?, :buyable?, :transactable_types, to: :instance

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

  def multiplte_transactable_types?
    self.transactable_types.count == 1
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
    domain.try(:name) || Rails.application.routes.default_url_options[:host]
  end

  def build_url_for_path(path)
    raise "Expected relative path, got #{path}" unless path[0] == '/'
    "http://#{host}#{path}"
  end

  def support_email_for(error_code)
    if self.is_desksnearme? || !self.support_email.present?
      "support+#{error_code}@desksnear.me"
    else
      support_email_splited = self.support_email.split('@')
      support_email_splited.join("+#{error_code}@")
    end
  end

  def contact_email
    @platform_context.theme.contact_email_with_fallback
  end

  def search_field_placeholder
    case instance.buyable?
    when false
      instance.searcher_type == 'fulltext' ? "Search by keyword" : "Search by city or address"
    when true
      'Search'
    end
  end

  def searcher_type
    instance.searcher_type
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

  def contact_email
    @platform_context.theme.contact_email_with_fallback
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
    @bookable_nouns ||= transactable_types.map { |tt| tt.bookable_noun.presence || tt.name }.to_sentence(last_word_connector: 'or')
  end

  def bookable_nouns_plural
    @bookable_nouns_plural ||= transactable_types.map { |tt| (tt.bookable_noun.presence || tt.name).pluralize }.to_sentence(last_word_connector: 'or')
  end



  private

  def platform_context
    @platform_context
  end

end
