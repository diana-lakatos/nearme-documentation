class Instance < ActiveRecord::Base
  has_paper_trail
  attr_accessible :name, :domains_attributes, :theme_attributes, :location_types_attributes, :listing_types_attributes,
                  :service_fee_guest_percent, :service_fee_host_percent, :bookable_noun, :lessor, :lessee,
                  :listing_amenity_types_attributes, :location_amenity_types_attributes, :skip_company, :pricing_options,
                  :live_stripe_api_key, :live_stripe_public_key, :live_paypal_username, :live_paypal_password, :live_paypal_signature, :live_paypal_app_id,
                  :live_paypal_client_id, :live_paypal_client_secret, :live_balanced_api_key, :instance_billing_gateways_attributes, :marketplace_password,
                  :translations_attributes, :test_stripe_api_key, :test_stripe_public_key, :test_paypal_username, :test_paypal_password,
                  :test_paypal_signature, :test_paypal_app_id, :test_paypal_client_id, :test_paypal_client_secret, :test_balanced_api_key,
                  :password_protected, :test_mode, :olark_api_key, :olark_enabled, :facebook_consumer_key, :facebook_consumer_secret, :twitter_consumer_key, 
                  :twitter_consumer_secret, :linkedin_consumer_key, :linkedin_consumer_secret, :instagram_consumer_key, :instagram_consumer_secret,
                  :paypal_email

  attr_encrypted :live_paypal_username, :live_paypal_password, :live_paypal_signature, :live_paypal_app_id, :live_stripe_api_key, :live_paypal_client_id,
                 :live_paypal_client_secret, :live_balanced_api_key, :marketplace_password, :test_stripe_api_key, :test_paypal_username, :test_paypal_password,
                 :test_paypal_signature, :test_paypal_app_id, :test_paypal_client_id, :test_paypal_client_secret, :test_balanced_api_key, :olark_api_key,
                 :facebook_consumer_key, :facebook_consumer_secret, :twitter_consumer_key, :twitter_consumer_secret, :linkedin_consumer_key, :linkedin_consumer_secret,
                 :instagram_consumer_key, :instagram_consumer_secret,
                 :key => DesksnearMe::Application.config.secret_token, :if => DesksnearMe::Application.config.encrypt_sensitive_db_columns

  has_one :theme, :as => :owner, dependent: :destroy

  has_many :companies, :inverse_of => :instance
  has_many :locations, :inverse_of => :instance
  has_many :locations_impressions, :through => :locations, :inverse_of => :instance
  has_many :location_types, :inverse_of => :instance
  has_many :listing_amenity_types, :inverse_of => :instance
  has_many :location_amenity_types, :inverse_of => :instance
  has_many :listings, :inverse_of => :instance
  has_many :listing_types, :inverse_of => :instance
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

  serialize :pricing_options, Hash

  validates_presence_of :name
  validates :pricing_options, presence: { message: :must_be_selected }
  validates_presence_of :marketplace_password, :if => :password_protected
  validates_presence_of :password_protected, :if => :test_mode, :message => I18n.t("activerecord.errors.models.instance.test_mode_needs_password")
  validates_length_of :olark_api_key, :minimum => 16, :maximum => 16, :allow_blank => true
  validates_presence_of :olark_api_key, :if => :olark_enabled

  after_initialize :set_all_pricing_options

  accepts_nested_attributes_for :domains, allow_destroy: true, reject_if: proc { |params| params[:name].blank? }
  accepts_nested_attributes_for :theme
  accepts_nested_attributes_for :location_types, allow_destroy: true, reject_if: proc { |params| params[:name].blank? }
  accepts_nested_attributes_for :listing_types, allow_destroy: true, reject_if: proc { |params| params[:name].blank? }
  accepts_nested_attributes_for :location_amenity_types, allow_destroy: true, reject_if: proc { |params| params[:name].blank? }
  accepts_nested_attributes_for :listing_amenity_types, allow_destroy: true, reject_if: proc { |params| params[:name].blank? }
  accepts_nested_attributes_for :translations, allow_destroy: true, reject_if: proc { |params| params[:value].blank? && params[:id].blank? }
  accepts_nested_attributes_for :instance_billing_gateways, allow_destroy: true, reject_if: proc { |params| params[:billing_gateway].blank? }

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
      attr_accessible "#{edge}_#{price}_price_cents", "#{edge}_#{price}_price"
    end
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

  def incoming_paypal_api_config
    @incoming_paypal_api_config ||= {
      :mode => (self.test_mode? || !Rails.env.production?) ? 'sandbox' : 'live',
      :client_id => billing_gateway_credential('paypal_client_id'),
      :client_secret => billing_gateway_credential('paypal_client_secret')
    }
  end

  def paypal_api_config
    @paypal_api_config ||= {
      :mode => (self.test_mode? || !Rails.env.production?) ? 'sandbox' : 'live',
      :app_id    => (self.test_mode? || !Rails.env.production?) ? 'APP-80W284485P519543T' : billing_gateway_credential('paypal_app_id'),
      :username  => billing_gateway_credential('paypal_username'),
      :password  => billing_gateway_credential('paypal_password'),
      :signature => billing_gateway_credential('paypal_signature')
    }
  end

  def to_liquid
    InstanceDrop.new(self)
  end

  def authenticate(password)
    password == marketplace_password
  end

  def billing_gateway_credential(credential)
    DesksnearMe::Application.config.send(credential).presence || send(credential).presence
  end

  private

  def set_all_pricing_options
    return if (!new_record? || !self.pricing_options.empty?)
    self.pricing_options = Hash[Instance::PRICING_OPTIONS.map{|po| [po, '1']}]
  end

end
