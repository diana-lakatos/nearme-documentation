class Instance < ActiveRecord::Base
  has_paper_trail

  has_metadata :accessors => [:support_metadata]

  # attr_accessible :name, :domains_attributes, :theme_attributes, :location_types_attributes,
  #                 :service_fee_guest_percent, :service_fee_host_percent, :bookable_noun, :lessor, :lessee,
  #                 :listing_amenity_types_attributes, :location_amenity_types_attributes, :skip_company,
  #                 :live_stripe_api_key, :live_stripe_public_key, :live_paypal_username, :live_paypal_password, :live_paypal_signature, :live_paypal_app_id,
  #                 :live_paypal_client_id, :live_paypal_client_secret, :live_balanced_api_key, :instance_billing_gateways_attributes, :marketplace_password,
  #                 :translations_attributes, :test_stripe_api_key, :test_stripe_public_key, :test_paypal_username, :test_paypal_password,
  #                 :test_paypal_signature, :test_paypal_app_id, :test_paypal_client_id, :test_paypal_client_secret, :test_balanced_api_key,
  #                 :password_protected, :test_mode, :olark_api_key, :olark_enabled, :facebook_consumer_key, :facebook_consumer_secret, :twitter_consumer_key,
  #                 :twitter_consumer_secret, :linkedin_consumer_key, :linkedin_consumer_secret, :instagram_consumer_key, :instagram_consumer_secret,
  #                 :password_protected, :test_mode, :olark_api_key, :olark_enabled, :facebook_consumer_key, :facebook_consumer_secret, :twitter_consumer_key,
  #                 :twitter_consumer_secret, :linkedin_consumer_key, :linkedin_consumer_secret, :instagram_consumer_key, :instagram_consumer_secret,
  #                 :support_imap_hash, :support_email, :paypal_email, :db_connection_string, :stripe_currency, :user_info_in_onboarding_flow, :default_search_view,
  #                 :user_based_marketplace_views, :instance_payment_gateways_attributes, :transactable_types_attributes, :searcher_type, :mark_as_locked

  attr_encrypted :live_paypal_username, :live_paypal_password, :live_paypal_signature, :live_paypal_app_id, :live_stripe_api_key, :live_paypal_client_id,
    :live_paypal_client_secret, :live_balanced_api_key, :marketplace_password, :test_stripe_api_key, :test_paypal_username, :test_paypal_password,
    :test_paypal_signature, :test_paypal_app_id, :test_paypal_client_id, :test_paypal_client_secret, :test_balanced_api_key, :olark_api_key,
    :facebook_consumer_key, :facebook_consumer_secret, :twitter_consumer_key, :twitter_consumer_secret, :linkedin_consumer_key, :linkedin_consumer_secret,
    :instagram_consumer_key, :instagram_consumer_secret, :db_connection_string,
    :key => DesksnearMe::Application.config.secret_token, :if => DesksnearMe::Application.config.encrypt_sensitive_db_columns

  attr_accessor :mark_as_locked
  serialize :user_required_fields, Array
  serialize :custom_sanitize_config, Hash

  API_KEYS = %w(paypal_username paypal_password paypal_signature paypal_app_id paypal_client_id paypal_client_secret stripe_api_key stripe_public_key balanced_api_key)

  API_KEYS.each do |meth|
    define_method(meth) do
      self.test_mode? ? self.send('test_' + meth) : self.send('live_' + meth)
    end
  end

  API_KEYS.each do |meth|
    define_method(meth + '=') do |arg|
      self.send('live_' + meth + '=', arg)
    end
  end

  belongs_to :instance_type
  has_one :theme, :as => :owner, dependent: :destroy

  has_many :companies, :inverse_of => :instance
  has_many :locations, :inverse_of => :instance
  has_many :locations_impressions, :through => :locations, :inverse_of => :instance
  has_many :location_types, :inverse_of => :instance
  has_many :listing_amenity_types, :inverse_of => :instance
  has_many :location_amenity_types, :inverse_of => :instance
  has_many :listings, class_name: "Transactable", :inverse_of => :instance
  has_many :domains, :as => :target
  has_many :partners, :inverse_of => :instance
  has_many :instance_admins, :inverse_of => :instance
  has_many :instance_admin_roles, :inverse_of => :instance
  has_many :reservations, :as => :platform_context_detail
  has_many :reservation_charges, :through => :reservations, :inverse_of => :instance
  has_many :instance_clients, :dependent => :destroy, :inverse_of => :instance
  has_many :translations, :dependent => :destroy, :inverse_of => :instance
  has_many :instance_billing_gateways, :dependent => :destroy, :inverse_of => :instance
  has_one :blog_instance, :as => :owner
  has_many :user_messages, :dependent => :destroy, :inverse_of => :instance
  has_many :faqs, class_name: 'Support::Faq'
  has_many :tickets, -> { where(target_type: 'Instance').order('created_at DESC') }, class_name: 'Support::Ticket'
  has_many :transactable_types
  has_many :instance_payment_gateways, :inverse_of => :instance
  has_many :country_instance_payment_gateways, :inverse_of => :instance
  has_many :users, inverse_of: :instance
  has_many :text_filters, inverse_of: :instance
  has_many :waiver_agreement_templates, as: :target
  has_many :approval_request_templates
  has_many :instance_profile_types
  has_one :instance_profile_type, -> { where(instance_id: PlatformContext.current.try(:instance).try(:id)) }
  has_many :data_uploads, as: :target
  serialize :pricing_options, Hash

  validates_presence_of :name
  validates_presence_of :marketplace_password, :if => :password_protected
  validates_presence_of :password_protected, :if => :test_mode, message: I18n.t("activerecord.errors.models.instance.test_mode_needs_password")
  validates_presence_of :olark_api_key, :if => :olark_enabled
  validates :payment_transfers_frequency, presence: true, inclusion: { in: PaymentTransfer::FREQUENCIES }

  accepts_nested_attributes_for :domains, allow_destroy: true, reject_if: proc { |params| params[:name].blank? }
  accepts_nested_attributes_for :theme
  accepts_nested_attributes_for :location_types, allow_destroy: true, reject_if: proc { |params| params[:name].blank? }
  accepts_nested_attributes_for :location_amenity_types, allow_destroy: true, reject_if: proc { |params| params[:name].blank? }
  accepts_nested_attributes_for :listing_amenity_types, allow_destroy: true, reject_if: proc { |params| params[:name].blank? }
  accepts_nested_attributes_for :translations, allow_destroy: true, reject_if: proc { |params| params[:value].blank? && params[:id].blank? }
  accepts_nested_attributes_for :instance_billing_gateways, allow_destroy: true, reject_if: proc { |params| params[:billing_gateway].blank? }
  accepts_nested_attributes_for :instance_payment_gateways, allow_destroy: true
  accepts_nested_attributes_for :transactable_types
  accepts_nested_attributes_for :text_filters, allow_destroy: true

  scope :with_support_imap, -> { where 'support_imap_hash IS NOT NULL AND support_imap_hash not like ?', '' }

  before_update :check_lock

  def authentication_supported?(provider)
    self.send(:"#{provider.downcase}_consumer_key").present? && self.send(:"#{provider.downcase}_consumer_secret").present?
  end

  PRICING_OPTIONS = %w(free hourly daily weekly monthly)

  PRICING_OPTIONS.each do |price|
    next if price == 'free'
    %w(min max).each do |edge|
      # Flag each price type as a Money attribute.
      # @see rails-money
      monetize "#{edge}_#{price}_price_cents", :allow_nil => true

      # Mark price fields as attr-accessible
      # attr_accessible "#{edge}_#{price}_price_cents", "#{edge}_#{price}_price"
    end
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
    self.master_lock.present?
  end

  def lock
    self.master_lock ||= Time.zone.now
  end

  def unlock
    self.master_lock = nil
  end

  def is_desksnearme?
    self.default_instance?
  end

  def white_label_enabled?
    true
  end

  def self.default_instance
    self.find_by_default_instance(true)
  end

  def lessor
    super.presence || "host"
  end

  def lessee
    super.presence || "guest"
  end

  def to_liquid
    InstanceDrop.new(self)
  end

  def authenticate(password)
    password == marketplace_password
  end

  def paypal_api_config
    settings = instance_payment_gateways.get_settings_for(:paypal)
    @paypal_api_config ||= {
      :app_id    => (self.test_mode? || !Rails.env.production?) ? 'APP-80W284485P519543T' : instance_payment_gateways.get_settings_for(:paypal, :app_id),
      :username  => settings[:username],
      :password  => settings[:password],
      :signature => settings[:signature]
    }
  end

  def buyable?
    @buyable ||= self.transactable_types.any?(&:buy_sell?)
  end

  def marketplace_type
    TransactableType::AVAILABLE_TYPES[buyable? ? 1 : 0]
  end

  def payment_gateway_mode
    test_mode? ? "test" : "live"
  end

  def onboarding_verification_required
    false
  end

  def onboarding_verification_required=(arg)
  end

  def next_payment_transfers_date(date=Time.zone.now)
    case payment_transfers_frequency
    when 'daily'
      date.tomorrow
    when 'semiweekly'
      date.wday >= 1 && date.wday < 4 ? date.beginning_of_week + 3.days : date.next_week
    when 'weekly'
      date.next_week
    when 'fortnightly'
      date.day >= 1 && date.day < 15 ? date.beginning_of_month + 2.weeks : date.next_month.beginning_of_month
    when 'monthly'
      date.next_month.beginning_of_month
    else
      raise NotImplementedError
    end
  end

  def generate_payment_transfers_today?
    today = Time.zone.today
    next_payment_transfers_date(today - 1.day) == today
  end
end
