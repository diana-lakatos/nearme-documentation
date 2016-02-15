class Company < ActiveRecord::Base
  include DomainsCacheable
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context
  URL_REGEXP = URI::regexp(%w(http https))
  has_metadata :accessors => [:industries_metadata]

  notify_associations_about_column_update([:payment_transfers, :payments, :reservations, :listings, :locations], [:instance_id, :partner_id])
  notify_associations_about_column_update([:reservations, :listings, :locations], [:creator_id, :listings_public])

  attr_accessor :created_payment_transfers, :bank_account_number, :bank_routing_number, :bank_owner_name, :verify_associated, :skip_industries

  has_many :approval_requests, as: :owner, dependent: :destroy
  has_many :company_industries, :dependent => :destroy
  has_many :company_users, dependent: :destroy
  has_many :data_uploads, as: :target
  has_many :industries, through: :company_industries
  has_many :instance_clients, as: :client, dependent: :destroy
  has_many :listings, class_name: 'Transactable', inverse_of: :company
  has_many :locations, dependent: :destroy, inverse_of: :company
  has_many :locations_impressions, source: :impressions, through: :locations
  has_many :merchant_accounts, as: :merchantable, dependent: :nullify
  MerchantAccount::MERCHANT_ACCOUNTS.each do |name, klass|
    # also include owners if association exist
    has_one :"#{name}_merchant_account",
      ->(record) {
        assoc = klass.reflections.keys.include?(:owners) ? includes(:owners) : self
        pg = klass::SEPARATE_TEST_ACCOUNTS && "PaymentGateway::#{name.classify}PaymentGateway".constantize.find_by(instance_id: (PlatformContext.current.try(:instance).try(:id) || record.instance_id))
        pg ? assoc.where(test: pg.test_mode?) : assoc
      },
      class_name: klass.to_s, as: :merchantable, dependent: :nullify
  end
  has_many :option_types, class_name: 'Spree::OptionType', dependent: :destroy
  has_many :orders, class_name: 'Spree::Order'
  has_many :order_line_items, class_name: 'Spree::LineItem'
  has_many :payments
  has_many :payment_transfers, dependent: :destroy
  has_many :photos, through: :listings
  has_many :products, class_name: 'Spree::Product', inverse_of: :company, dependent: :destroy
  has_many :products_images, through: :products, source: :variant_images
  has_many :products_impressions, source: :impressions, through: :products
  has_many :properties, class_name: 'Spree::Property', dependent: :destroy
  has_many :prototypes, class_name: 'Spree::Prototype', dependent: :destroy
  has_many :reservations
  has_many :shipping_categories, class_name: 'Spree::ShippingCategory', dependent: :destroy
  has_many :shipping_methods, class_name: 'Spree::ShippingMethod', dependent: :destroy
  has_many :stock_locations, class_name: 'Spree::StockLocation', dependent: :destroy
  has_many :tax_categories, class_name: 'Spree::TaxCategory', dependent: :destroy
  has_many :users, :through => :company_users
  has_many :variants, class_name: 'Spree::Variant', dependent: :destroy
  has_many :waiver_agreement_templates, as: :target
  has_many :zones, class_name: 'Spree::Zone', dependent: :destroy

  has_one :company_address, class_name: 'Address', as: :entity
  has_one :domain, :as => :target, foreign_key: 'target_id', :dependent => :destroy
  has_one :theme, as: :owner, foreign_key: 'owner_id', dependent: :destroy

  belongs_to :creator, -> { with_deleted }, class_name: "User", inverse_of: :created_companies
  belongs_to :instance
  belongs_to :partner
  belongs_to :payments_mailing_address, class_name: 'Address', foreign_key: 'mailing_address_id'

  before_validation :add_default_url_scheme
  before_save :set_creator_address

  validates_presence_of :name
  validates_presence_of :industries, :if => proc { |c| c.instance.present? && c.instance.has_industries? && !c.instance.skip_company? && !c.skip_industries }
  validates_length_of :description, :maximum => 250
  validates_length_of :name, :maximum => 50
  validates :email, email: true, allow_blank: true
  validate :validate_url_format

  delegate :address, :address2, :formatted_address, :postcode, :suburb, :city, :state, :country, :street, :address_components,
    :latitude, :longitude, :state_code, :street_number, to: :company_address, allow_nil: true
  delegate :service_fee_guest_percent, :service_fee_host_percent, to: :instance, allow_nil: true
  delegate :first_name, :last_name, :mobile_number, to: :creator

  # Returns the companies in need of recieving a payment transfer for
  # outstanding payments we've received on their behalf.
  #
  # NB: Will probably need to optimize this at some point
  scope :needs_payment_transfer, -> {
    joins(:payments).merge(Payment.needs_payment_transfer)
  }

  accepts_nested_attributes_for :domain, :reject_if => proc { |params| params.delete(:white_label_enabled).to_f.zero? }
  accepts_nested_attributes_for :theme, reject_if: proc { |params| params.delete(:white_label_enabled).to_f.zero? }
  accepts_nested_attributes_for :locations
  accepts_nested_attributes_for :company_address
  accepts_nested_attributes_for :payments_mailing_address
  accepts_nested_attributes_for :approval_requests
  accepts_nested_attributes_for :products, :shipping_methods, :shipping_categories, :stock_locations
  MerchantAccount::MERCHANT_ACCOUNTS.each do |name, _|
    accepts_nested_attributes_for "#{name}_merchant_account".to_sym, allow_destroy: true, update_only: true
  end

  validates_associated :shipping_methods, if: :verify_associated
  validates_associated :shipping_categories, if: :verify_associated
  validates_associated :products, if: :verify_associated
  validates_associated :stock_locations, if: :verify_associated

  validates :paypal_email, email: true, allow_blank: true

  after_create :add_company_to_partially_created_shipping_categories

  def email
    super.presence || creator.try(:email)
  end

  def iso_country_code
    company_address.try(:iso_country_code) || instance.default_country_code
  end

  def add_company_to_partially_created_shipping_categories
    if self.creator_id.present?
      partial_categories = Spree::ShippingCategory.where(:user_id => self.creator_id, :company_id => nil)
      partial_categories.each do |partial_category|
        partial_category.update_attribute(:company_id, self.id)
      end
    end

    true
  end

  def add_creator_to_company_users
    unless users.include?(creator)
      users << creator
    end
  end

  def self.xml_attributes
    self.csv_fields.keys
  end

  # Schedules a new payment transfer for current outstanding payments for each
  # of the currency payments recieved by the Company.
  def schedule_payment_transfer
    self.created_payment_transfers = []
    transaction do
      charges_without_payment_transfer = payments.needs_payment_transfer
      charges_without_payment_transfer.group_by(&:currency).each do |currency, all_charges|
        all_charges.group_by(&:payment_gateway_mode).each do |mode, charges|
          payment_transfer = payment_transfers.create!(payments: charges, payment_gateway_mode: mode)
          self.created_payment_transfers << payment_transfer if possible_payout_not_configured?(instance.payout_gateway(iso_country_code, currency))
        end
      end
    end
    # we want to notify company owner (once no matter how many payment transfers have been generated!)
    # that it is possible to make automated payout but he needs to enter credentials via edit company settings
    if mailing_address.blank? && self.created_payment_transfers.any?
      WorkflowStepJob.perform(WorkflowStep::PayoutWorkflow::NoPayoutOption, self.id, self.created_payment_transfers)
    end
  end

  def payout_payment_gateway
    if @payment_gateway.nil?
      currency = locations.first.try(:listings).try(:first).try(:currency).presence || 'USD'
      @payment_gateway = instance.payout_gateway(iso_country_code, currency)
    end
    @payment_gateway
  end

  def boarding_payment_gateway
    currency = locations.first.try(:listings).try(:first).try(:currency).presence || 'USD'
    @boarding_payment_gateway ||= PaymentGateway.where(instance: instance).all.find do |pg|
      pg.supports_currency?(currency) && pg.payout_supports_country?(iso_country_code) && pg.supports_paypal_chain_payments?
    end
  end

  def possible_payout_not_configured?(payment_gateway)
    payment_gateway.try(:supports_payout?) && merchant_accounts.verified_on_payment_gateway(payment_gateway.id).count.zero?
  end

  def to_liquid
    @company_drop ||= CompanyDrop.new(self)
  end

  def address_to_shippo
    ShippoApi::ShippoFromAddressFillerFromSpree.new(self)
  end

  def add_default_url_scheme
    if url.present? && !/^(http|https):\/\//.match(url)
      new_url = "http://#{url}"
      self.url = new_url if URL_REGEXP.match(new_url)
    end
  end

  def validate_url_format
    return if url.blank?

    valid = URL_REGEXP.match(url)
    valid &&= begin
                URI.parse(url)
              rescue
                false
              end

    errors.add(:url, "must be a valid URL") unless valid
  end

  def self.csv_fields
    { name: 'Company Name', url: 'Company Website', email: 'Company Email', external_id: 'Company External Id', company_industries_list: 'Company Industries' }
  end

  def approval_request_templates
      @approval_request_templates ||= PlatformContext.current.instance.approval_request_templates.for("Company").older_than(created_at)
  end

  def current_approval_requests
    self.approval_requests.to_a.reject { |ar| !self.approval_request_templates.pluck(:id).include?(ar.approval_request_template_id) }
  end

  def is_trusted?
    if approval_request_templates.count > 0
      self.approval_requests.approved.count > 0
    else
      self.creator.try(:is_trusted?)
    end
  end

  def approval_request_acceptance_cancelled!
    listings.find_each(&:approval_request_acceptance_cancelled!)
  end

  def approval_request_approved!
    listings.find_each(&:approval_request_approved!)
  end

  def rfq_count
    Support::Ticket.for_filter('open').where('target_type = ? AND target_id IN (?)', 'Transactable', listings.pluck(:id)).count
  end

  def mailing_address
    if payments_mailing_address.present?
      payments_mailing_address.address
    else
      read_attribute(:mailing_address)
    end
  end

  def set_creator_address
    if company_address.nil? && instance.skip_company
      if creator.present? && country_name = creator.reload.country.try(:name)
        build_company_address(address: country_name).fetch_coordinates!
      end
    end
  end

  def time_zone
    if latitude && longitude
      ActiveSupport::TimeZone::MAPPING.select {|k, v| v == NearestTimeZone.to(latitude, longitude) }.keys.first
    else
     creator.time_zone
    end
  end

end

