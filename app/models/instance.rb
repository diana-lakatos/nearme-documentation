# frozen_string_literal: true
class Instance < ActiveRecord::Base
  include Encryptable
  include DomainsCacheable
  include ShippoLegacy::Instance
  include Shippings::Instance

  SELLER_ATTACHMENTS_ACCESS_LEVELS = (Ckeditor::Asset::ACCESS_LEVELS + ['sellers_preference']).freeze

  has_paper_trail

  has_metadata accessors: [:support_metadata]

  attr_encrypted :marketplace_password, :olark_api_key,
                 :facebook_consumer_key, :facebook_consumer_secret, :twitter_consumer_key, :twitter_consumer_secret, :linkedin_consumer_key, :linkedin_consumer_secret,
                 :instagram_consumer_key, :instagram_consumer_secret, :db_connection_string,
                 :twilio_consumer_key, :twilio_consumer_secret, :test_twilio_consumer_key, :test_twilio_consumer_secret, :support_imap_password, :webhook_token,
                 :google_consumer_key, :google_consumer_secret, :github_consumer_key, :github_consumer_secret, :google_maps_api_key

  attr_accessor :mark_as_locked
  attr_accessor :custom_translations
  serialize :custom_sanitize_config, Hash
  serialize :hidden_ui_controls, Hash
  serialize :allowed_countries, Array
  serialize :allowed_currencies, Array
  serialize :orders_received_tabs, Array
  serialize :my_orders_tabs, Array
  serialize :password_validation_rules, Hash

  SEARCH_TYPES = %w(geo fulltext fulltext_geo fulltext_category geo_category).freeze
  SEARCH_ENGINES = %w(postgresql elasticsearch).freeze
  SEARCH_MODULES = { 'elasticsearch' => 'Elastic' }.freeze
  SEARCHABLE_CLASSES = %w(TransactableType InstanceProfileType).freeze
  CLASSES_WITH_ES_INDEX = [Transactable, User].freeze

  has_one :theme, as: :owner
  has_one :custom_theme, -> { where(in_use: true) }, as: :themeable
  has_one :custom_theme_for_instance_admins, -> { where(in_use_for_instance_admins: true) }, as: :themeable, class_name: 'CustomTheme'
  has_many :api_keys
  has_many :custom_themes, as: :themeable
  has_many :companies, inverse_of: :instance
  has_many :form_configurations, dependent: :destroy
  has_many :locations, inverse_of: :instance
  has_many :locations_impressions, through: :locations, source: :impressions, class_name: 'Impression'
  has_many :location_types, inverse_of: :instance
  has_many :listings, class_name: 'Transactable', inverse_of: :instance
  has_many :listings_impressions, through: :listings, source: :impressions, class_name: 'Impression'
  has_many :domains, as: :target, dependent: :destroy
  has_many :partners, inverse_of: :instance
  has_many :instance_admins, inverse_of: :instance
  has_many :instance_admin_roles, inverse_of: :instance
  has_many :reservations
  has_many :reservation_types, inverse_of: :instance
  has_many :orders
  has_many :payments
  has_many :payment_transfers
  has_many :instance_clients, dependent: :destroy, inverse_of: :instance
  has_many :translations, dependent: :destroy, inverse_of: :instance
  has_many :instance_billing_gateways, dependent: :destroy, inverse_of: :instance
  has_one :blog_instance, as: :owner
  has_many :user_messages, dependent: :destroy, inverse_of: :instance
  has_many :faqs, class_name: 'Support::Faq'
  has_many :tickets, -> { where(target_type: 'Instance').order('created_at DESC') }, class_name: 'Support::Ticket'
  has_many :transactable_types
  has_many :action_types, class_name: 'TransactableType::ActionType'
  # @todo Remove project_types when {ProjectType} will be finally removed
  has_many :project_types, class_name: 'ProjectType'
  has_many :all_payment_gateways, class_name: 'PaymentGateway'
  has_many :users, inverse_of: :instance
  has_many :text_filters, inverse_of: :instance
  has_many :waiver_agreement_templates, as: :target
  has_many :approval_request_templates
  has_many :instance_profile_types
  has_one :default_profile_type, -> { default }, class_name: 'InstanceProfileType'
  has_one :seller_profile_type, -> { seller }, class_name: 'InstanceProfileType'
  has_one :buyer_profile_type, -> { buyer }, class_name: 'InstanceProfileType'
  has_many :data_uploads, as: :target
  has_many :user_blog_posts
  has_many :instance_views
  has_many :rating_systems, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :rating_questions
  has_many :rating_answers
  has_many :rating_hints
  has_many :additional_charge_types, foreign_type: :charge_type_target_type, foreign_key: :charge_type_target_id
  has_one :documents_upload, dependent: :destroy
  has_many :locales, dependent: :destroy
  has_many :dimensions_templates, as: :entity
  has_many :seller_attachments
  has_many :availability_templates, as: :parent
  has_many :custom_validators
  has_many :form_components, as: :form_componentable, dependent: :destroy
  has_many :scheduled_uploaders_regenerations
  has_many :aws_certificates
  has_many :graph_queries

  validates :id, uniqueness: true
  validates :name, presence: true, length: { maximum: 255 }
  validates :marketplace_password, presence: { if: :password_protected }, length: { maximum: 255 }
  validates :password_protected, presence: { if: :test_mode, message: I18n.t('activerecord.errors.models.instance.test_mode_needs_password') }
  validates :olark_api_key, presence: { if: :olark_enabled }
  validates :payment_transfers_frequency, presence: true, inclusion: { in: PaymentTransfer::FREQUENCIES }
  validates :seller_attachments_access_level, inclusion: { in: SELLER_ATTACHMENTS_ACCESS_LEVELS + ['disabled'] }
  validates :support_email, length: { maximum: 255 }
  validates :support_imap_username, length: { maximum: 255 }
  validates :support_imap_password, length: { maximum: 255 }
  validates :support_imap_server, length: { maximum: 255 }
  validates :timeout_in_minutes, numericality: { only_integer: true }

  validates_with PasswordRulesValidator

  accepts_nested_attributes_for :domains, allow_destroy: true, reject_if: proc { |params| params[:name].blank? && params.key?(:name) }
  accepts_nested_attributes_for :theme
  accepts_nested_attributes_for :location_types, allow_destroy: true, reject_if: proc { |params| params[:name].blank? }
  accepts_nested_attributes_for :translations, allow_destroy: true, reject_if: proc { |params| params[:value].blank? && params[:id].blank? }
  accepts_nested_attributes_for :instance_billing_gateways, allow_destroy: true, reject_if: proc { |params| params[:billing_gateway].blank? }
  accepts_nested_attributes_for :all_payment_gateways, allow_destroy: true
  accepts_nested_attributes_for :transactable_types
  accepts_nested_attributes_for :text_filters, allow_destroy: true

  delegate :force_file_upload?, to: :documents_upload, allow_nil: true

  scope :with_support_imap, -> { where("support_imap_username <> '' AND encrypted_support_imap_password  <> '' AND support_imap_server  <> '' AND support_imap_port IS NOT NULL") }

  scope :with_deleted, -> { all }

  store_accessor :search_settings, :tt_select_type

  before_create :generate_webhook_token
  before_update :check_lock
  after_save :recalculate_cache_key!, if: -> { custom_sanitize_config_changed? }

  def authentication_supported?(provider)
    send(:"#{provider.downcase}_consumer_key").present? && send(:"#{provider.downcase}_consumer_secret").present?
  end

  def allowed_country_list
    Country.where(name: allowed_countries)
  end

  def allowed_currencies=(currencies)
    self[:allowed_currencies] = currencies.select(&:present?)
  end

  def allowed_countries=(countries)
    self[:allowed_countries] = countries.select(&:present?)
  end

  def check_lock
    return if mark_as_locked.nil?
    if mark_as_locked == '1'
      lock
    else
      unlock
    end
  end

  def locked?
    master_lock.present?
  end

  def lock
    self.master_lock ||= Time.zone.now
  end

  def unlock
    self.master_lock = nil
  end

  def white_label_enabled?
    true
  end

  def lessor
    self[:lessor].presence || 'host'
  end

  def lessee
    self[:lessee].presence || 'guest'
  end

  def to_liquid
    @instance_drop ||= InstanceDrop.new(self)
  end

  def authenticate(password)
    password == marketplace_password
  end

  def blogging_enabled?(user)
    (!split_registration && user_blogs_enabled?) || (user.buyer_profile.present? && enquirer_blogs_enabled?) || (user.seller_profile.present? && lister_blogs_enabled?)
  end

  def twilio_config
    if !test_mode? && Rails.env.production?
      if twilio_consumer_key.present? && twilio_consumer_secret.present? && twilio_from_number.present?
        { key: twilio_consumer_key, secret: twilio_consumer_secret, from: twilio_from_number }
      else
        default_twilio_config
      end
    else
      if test_twilio_consumer_key.present? && test_twilio_consumer_secret.present? && test_twilio_from_number.present?
        { key: test_twilio_consumer_key, secret: test_twilio_consumer_secret, from: test_twilio_from_number }
      else
        default_test_twilio_config
      end
    end
  end

  def test_mode?
    self[:test_mode] || (!Rails.env.staging? && !Rails.env.production?)
  end

  def guest_fee_enabled?
    action_types.where('service_fee_guest_percent != 0').any?
  end

  def host_fee_enabled?
    action_types.where('service_fee_host_percent != 0').any?
  end

  def default_twilio_config
    {
      key: 'AC5b979a4ff2aa576bafd240ba3f56c3ce',
      secret: '0f9a2a5a9f847b0b135a94fe2aa7f346',
      from: '+1 510-478-9196'
    }
  end

  def default_test_twilio_config
    {
      key: 'AC83d13764f96b35292203c1a276326f5d',
      secret: '709625e20011ace4b8b53a5a04160026',
      from: '+15005550006'
    }
  end

  def default_country_code
    Country.find_by(name: default_country).try(:iso)
  end

  def payment_gateways(country, currency)
    PaymentGateway.payment_type.mode_scope.joins(:payment_countries, :payment_currencies).where(currencies: { iso_code: currency }, countries: { iso: country }).distinct(:id)
  end

  def payment_gateway(country, currency)
    payment_gateways(country, currency).first
  end

  def payout_gateways(country, currency)
    PaymentGateway.payout_type.mode_scope.joins(:payment_countries, :payment_currencies).where(currencies: { iso_code: currency }, countries: { iso: country }).distinct(:id)
  end

  def payout_gateway(country, currency)
    payout_gateways(country, currency).first
  end

  # @return [Boolean] whether bookable/purchaseable {TransactableType} objects have been defined for this instance
  def bookable?
    @bookable ||= action_types.bookable.enabled.joins(:transactable_type).where(transactable_types: { deleted_at: nil }).any?
  end

  def projectable?
    @projectable ||= project_types.any?
  end

  def marketplace_type
    TransactableType::AVAILABLE_TYPES[0]
  end

  # @return [Boolean] whether the payment transfers frequency is set to manual
  def manual_transfers?
    payment_transfers_frequency == 'manually'
  end

  def payment_gateway_mode
    test_mode? ? PaymentGateway::TEST_MODE : PaymentGateway::LIVE_MODE
  end

  def onboarding_verification_required
    false
  end

  def onboarding_verification_required=(_arg)
  end

  def default_domain
    domains.order('use_as_default desc').try(:first)
  end

  # @return [Boolean] whether documents upload is enabled
  def documents_upload_enabled?
    documents_upload.present? && documents_upload.enabled?
  end

  def annotated_id
    "#{id} - #{name}"
  end

  # @return [Boolean] whether any of the action types have request for quotation enabled
  def action_rfq?
    action_types.enabled.where(allow_action_rfq: true).any?
  end

  def custom_translations=(translations)
    %w(buy_sell_market.checkout.manual_payment buy_sell_market.checkout.manual_payment_description).each do |key|
      t = Translation.where(instance_id: id, key: key, locale: I18n.locale).first_or_initialize
      t.update_attribute(:value, translations[key])
    end
  end

  def primary_locale
    Rails.cache.fetch("locale.primary_#{cache_key}") do
      locales.default_locale || :en
    end
  end

  def available_locales
    Rails.cache.fetch("locale.available_#{cache_key}") do
      locales.pluck(:code).map(&:to_sym)
    end
  end

  def default_currency
    self[:default_currency].presence || 'USD'
  end

  def set_context!
    PlatformContext.current = PlatformContext.new(self)
  end

  def signature
    [id, 'Instance'].join(',')
  end

  def recalculate_cache_key!
    update_column(:context_cache_key, [custom_theme.try(:updated_at), custom_theme_for_instance_admins.try(:updated_at), Digest::SHA1.hexdigest(custom_sanitize_config.to_s + text_filters.pluck(:id, :updated_at).to_s), Time.now.to_s].join('timestamp'))
  end

  def require_payout?
    !test_mode? && require_payout_information?
  end

  def fast_recalculate_cache_key!
    # this is needed, otherwise it won't matter that we update context_cache - we will use cached, old one due to domain
    domains.pluck(:name).each { |name| Rails.cache.delete("domains_cache_#{name}") }
    if context_cache_key
      update_column(:context_cache_key, [context_cache_key.split('timestamp').first, Time.now.to_i].join('timestamp'))
    else
      recalculate_cache_key!
    end
  end

  def instance_owner
    instance_admins.find_by(instance_owner: true).try(:user)
  end

  def generate_webhook_token
    self.webhook_token = SecureRandom.uuid.delete('-')
  end

  # @return [Boolean] whether seller attachments are enabled for this marketplace
  def seller_attachments_enabled
    seller_attachments_access_level != 'disabled'
  end
  alias seller_attachments_enabled? seller_attachments_enabled

  def seller_attachments_enabled=(val)
    self.seller_attachments_access_level = 'disabled' if val == '0'
  end

  SELLER_ATTACHMENTS_ACCESS_LEVELS.each do |access_level|
    define_method "seller_attachments_access_#{access_level}?" do
      seller_attachments_access_level == access_level
    end
  end

  def build_availability_templates
    unless availability_templates.any?
      availability_templates.build(
        name: 'Working Week',
        instance: self,
        description: 'Mon - Fri, 9:00 AM - 5:00 PM',
        availability_rules_attributes: [{
          days: (1..5).to_a,
          instance: self,
          open_hour: 9, open_minute: 0,
          close_hour: 17, close_minute: 0
        }]
      )

      availability_templates.build(
        name: '24/7',
        instance: self,
        description: 'Sunday - Saturday, 12am-11:59pm',
        availability_rules_attributes: [{
          days: (0..6).to_a,
          instance: self,
          open_hour: 0, open_minute: 0,
          close_hour: 23, close_minute: 59
        }]
      )
    end
  end

  def seller_profile_enabled?
    seller_profile_type.form_components.where(form_type: 'seller_profile_types').any?
  end

  def buyer_profile_enabled?
    buyer_profile_type.form_components.where(form_type: 'buyer_profile_types').any?
  end

  def default_profile_enabled?
    default_profile_type.form_components.where(form_type: 'default_profile_types').any?
  end

  def new_ui?
    Rails.logger.error("ERROR! new_ui? method should be deprecated, called from: #{caller[0]}")
    true
  end

  def searchable_classes
    SEARCHABLE_CLASSES.map do |searchable_class|
      _klass = searchable_class.constantize
      _klass::DEPENDENT_CLASS if _klass.searchable.any?
    end.compact
  end
end
