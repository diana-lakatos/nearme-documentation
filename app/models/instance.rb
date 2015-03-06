class Instance < ActiveRecord::Base
  has_paper_trail

  has_metadata :accessors => [:support_metadata]

  attr_encrypted :live_paypal_username, :live_paypal_password, :live_paypal_signature, :live_paypal_app_id, :live_stripe_api_key, :live_paypal_client_id,
    :live_paypal_client_secret, :live_balanced_api_key, :marketplace_password, :test_stripe_api_key, :test_paypal_username, :test_paypal_password,
    :test_paypal_signature, :test_paypal_app_id, :test_paypal_client_id, :test_paypal_client_secret, :test_balanced_api_key, :olark_api_key,
    :facebook_consumer_key, :facebook_consumer_secret, :twitter_consumer_key, :twitter_consumer_secret, :linkedin_consumer_key, :linkedin_consumer_secret,
    :instagram_consumer_key, :instagram_consumer_secret, :db_connection_string, :shippo_username, :shippo_password,
    :twilio_consumer_key, :twilio_consumer_secret, :test_twilio_consumer_key, :test_twilio_consumer_secret, :support_imap_password,
    :key => DesksnearMe::Application.config.secret_token, :if => DesksnearMe::Application.config.encrypt_sensitive_db_columns

  attr_accessor :mark_as_locked
  serialize :user_required_fields, Array
  serialize :custom_sanitize_config, Hash
  serialize :hidden_ui_controls, Hash

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
  has_many :domains, :as => :target, dependent: :destroy
  has_many :partners, :inverse_of => :instance
  has_many :instance_admins, :inverse_of => :instance
  has_many :instance_admin_roles, :inverse_of => :instance
  has_many :reservations, :as => :platform_context_detail
  has_many :orders, :as => :platform_context_detail
  has_many :payments, :through => :reservations, :inverse_of => :instance
  has_many :instance_clients, :dependent => :destroy, :inverse_of => :instance
  has_many :translations, :dependent => :destroy, :inverse_of => :instance
  has_many :instance_billing_gateways, :dependent => :destroy, :inverse_of => :instance
  has_one :blog_instance, :as => :owner
  has_many :user_messages, :dependent => :destroy, :inverse_of => :instance
  has_many :faqs, class_name: 'Support::Faq'
  has_many :tickets, -> { where(target_type: 'Instance').order('created_at DESC') }, class_name: 'Support::Ticket'
  has_many :transactable_types
  has_many :product_types, class_name: "Spree::ProductType"
  has_many :instance_payment_gateways, :inverse_of => :instance
  has_many :country_instance_payment_gateways, :inverse_of => :instance
  has_many :users, inverse_of: :instance
  has_many :text_filters, inverse_of: :instance
  has_many :waiver_agreement_templates, as: :target
  has_many :approval_request_templates
  has_many :instance_profile_types
  has_one :instance_profile_type, -> { where(instance_id: PlatformContext.current.try(:instance).try(:id)) }
  has_many :data_uploads, as: :target
  has_many :industries
  has_many :user_blog_posts
  has_many :instance_views
  has_many :dimensions_templates
  has_many :rating_systems, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :rating_questions
  has_many :rating_answers
  has_many :rating_hints
  has_many :additional_charge_types
  has_one :documents_upload, dependent: :destroy
  serialize :pricing_options, Hash

  validates_presence_of :name
  validates_presence_of :marketplace_password, :if => :password_protected
  validates_presence_of :password_protected, :if => :test_mode, message: I18n.t("activerecord.errors.models.instance.test_mode_needs_password")
  validates_presence_of :olark_api_key, :if => :olark_enabled
  validates :payment_transfers_frequency, presence: true, inclusion: { in: PaymentTransfer::FREQUENCIES }

  accepts_nested_attributes_for :domains, allow_destroy: true, reject_if: proc { |params| params[:name].blank? && params.has_key?(:name) }
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

  PRICING_OPTIONS = %w(free hourly daily weekly monthly fixed)

  PRICING_OPTIONS.each do |price|
    next if price == 'free'
    next if price == 'fixed'
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

  def white_label_enabled?
    true
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

  def twilio_config
    if (!self.test_mode? && Rails.env.production?)
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
    super || (!Rails.env.staging? && !Rails.env.production?)
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
    @buyable ||= product_types.any?
  end

  def bookable?
    @bookable ||= transactable_types.services.any?
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

  def has_industries?
    industries.any?
  end

  def default_domain
    domains.order('use_as_default desc').try(:first)
  end

  def buyable_transactable_type
    self.transactable_types.where(name: TransactableType::AVAILABLE_TYPES[1]).first
  end

  def documents_upload_enabled?
    self.documents_upload.present? && self.documents_upload.enabled?
  end
end
