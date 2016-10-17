# frozen_string_literal: true
class PlatformContextDecorator
  delegate :white_label_company, :instance, :theme, :partner, :domain, :white_label_company_user?, :project_space_wizard_path,
           :platform_context_detail, :secured_constraint, to: :platform_context

  delegate :tagline, :support_url, :blog_url, :twitter_url, :twitter_handle, :facebook_url, :gplus_url, :instagram_url,
           :youtube_url, :rss_url, :linkedin_url, :address, :phone_number, :phone_number_noformat, :site_name, :description, :support_email, :meta_title, :pages,
           :hero_image, :logo_image, :favicon_image, :icon_image, :icon_retina_image, :call_to_action, :is_company_theme?,
           :content_holders, to: :theme

  delegate :bookable_noun, :lessor, :lessee, :name, :buyable?, :bookable?, :projectable?, :biddable?,
           :transactable_types, :project_types, :wish_lists_icon_set, :seller_attachments_enabled?, :action_rfq?,
           :wish_lists_enabled?, :active_rating_systems_present?, :webhook_token, :enable_geo_localization,
           :enquirer_blogs_enabled, :lister_blogs_enabled, :debugging_mode_for_admins?, to: :instance

  def initialize(platform_context)
    @platform_context = platform_context
  end

  def single_type?
    transactable_types.count == 1
  end

  # @return [Array<TransactableType>] array of transactable types for this marketplace;
  #   added for reverse compatibility
  def service_types
    @platform_context.transactable_types
  end

  def to_liquid
    @platform_context_drop ||= PlatformContextDrop.new(self)
  end

  # @return [String] plural of {Instance#lessor}
  # @deprecated use {TransactableType#lessor} instead
  def lessors
    lessor.pluralize
  end

  # @return [String] plural of {Instance#lessee}
  # @deprecated use {TransactableType#lessee} instead
  def lessees
    lessee.pluralize
  end

  def host
    domain.name
  end

  def build_url_for_path(path)
    raise "Expected relative path, got #{path}" unless path[0] == '/'
    "https://#{host}#{path}"
  end

  def support_email_for(error_code)
    support_email_splited = support_email.split('@')
    support_email_splited.join("+#{error_code}@")
  end

  def contact_email
    @platform_context.theme.contact_email_with_fallback
  end

  # @return [String] placeholder for the search box on the homepage
  def search_by_keyword_placeholder
    I18n.t('homepage.search_field_placeholder.full_text')
  end

  def platform_context_detail_key
    @platform_context_detail_key = "#{platform_context_detail.class.to_s.downcase}_#{platform_context_detail.id}"
  end

  def normalize_timestamp(timestamp)
    timestamp.try(:utc).try(:to_s, :number)
  end

  # @return [String] sentence containing all the bookable nouns available on this platform
  def bookable_nouns
    @bookable_nouns ||= transactable_types.map(&:translated_bookable_noun).to_sentence(last_word_connector: I18n.t('general.or_spaced'))
  end

  # @return [String] sentence containing all the bookable nouns (pluralized) available on this platform
  def bookable_nouns_plural
    @bookable_nouns_plural ||= transactable_types.map { |tt| tt.translated_bookable_noun(10) }.to_sentence(last_word_connector: I18n.t('general.or_spaced'))
  end

  # @return [String] Facebook consumer key for this instance
  def facebook_key
    Rails.env.development? || Rails.env.test? ? DesksnearMe::Application.config.facebook_key : instance.facebook_consumer_key
  end

  private

  attr_reader :platform_context
end
