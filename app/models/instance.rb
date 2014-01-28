class Instance < ActiveRecord::Base
  has_paper_trail
  attr_accessible :name, :domains_attributes, :theme_attributes, :location_types_attributes, :listing_types_attributes,
                  :service_fee_guest_percent, :service_fee_host_percent, :bookable_noun, :lessor, :lessee,
                  :listing_amenity_types_attributes, :location_amenity_types_attributes, :skip_company, :pricing_options,
                  :stripe_api_key, :stripe_public_key, :paypal_username, :paypal_password, :paypal_signature, :paypal_app_id, 
                  :paypal_client_id, :paypal_client_secret, :balanced_api_key, :translations_attributes

  attr_encrypted :paypal_username, :paypal_password, :paypal_signature, :paypal_app_id, :stripe_api_key,
    :paypal_client_id, :paypal_client_secret, :balanced_api_key, :key => DesksnearMe::Application.config.secret_token, :if => DesksnearMe::Application.config.encrypt_sensitive_db_columns

  has_one :theme, :as => :owner, dependent: :destroy

  has_many :companies
  has_many :locations, :through => :companies
  has_many :locations_impressions,
           :through => :companies
  has_many :location_types
  has_many :listing_amenity_types
  has_many :location_amenity_types
  has_many :listings, :through => :locations
  has_many :listing_types
  has_many :domains, :as => :target
  has_many :partners
  has_many :instance_admins
  has_many :instance_admin_roles
  has_many :reservations, :as => :platform_context_detail, :dependent => :destroy
  has_many :reservation_charges, :through => :reservations
  has_many :translations, :dependent => :destroy

  serialize :pricing_options, Hash

  validates_presence_of :name
  validates :pricing_options, presence: { message: :must_be_selected }

  after_initialize :set_all_pricing_options

  accepts_nested_attributes_for :domains, allow_destroy: true, reject_if: proc { |params| params[:name].blank? }
  accepts_nested_attributes_for :theme, reject_if: proc { |params| params[:name].blank? }
  accepts_nested_attributes_for :location_types, allow_destroy: true, reject_if: proc { |params| params[:name].blank? }
  accepts_nested_attributes_for :listing_types, allow_destroy: true, reject_if: proc { |params| params[:name].blank? }
  accepts_nested_attributes_for :location_amenity_types, allow_destroy: true, reject_if: proc { |params| params[:name].blank? }
  accepts_nested_attributes_for :listing_amenity_types, allow_destroy: true, reject_if: proc { |params| params[:name].blank? }
  accepts_nested_attributes_for :translations, allow_destroy: true, reject_if: proc { |params| params[:value].blank? }

  PRICING_OPTIONS = %w(free hourly daily weekly monthly)

  def custom_stripe_api_key
    self.stripe_api_key.presence || Stripe.api_key
  end

  def custom_stripe_public_key
    self.stripe_public_key.presence || DesksnearMe::Application.config.stripe_public_key
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

  def paypal_api_config
    @paypal_api_config ||= {
      :mode => DesksnearMe::Application.config.paypal_mode,
      :client_id => self.paypal_client_id,
      :client_secret => self.paypal_client_secret,
      :app_id    => self.paypal_app_id,
      :username  => self.paypal_username,
      :password  => self.paypal_password,
      :signature => self.paypal_signature
    }
  end

  def paypal_supported?
    self.paypal_username.present? &&
    self.paypal_password.present? &&
    self.paypal_signature.present? &&
    self.paypal_client_id.present? &&
    self.paypal_client_secret.present? &&
    self.paypal_app_id.present?
  end


  def to_liquid
    InstanceDrop.new(self)
  end

  private

  def set_all_pricing_options
    return if (!new_record? || !self.pricing_options.empty?)
    self.pricing_options = Hash[Instance::PRICING_OPTIONS.map{|po| [po, '1']}]
  end
end
