# frozen_string_literal: true
require 'nearest_time_zone'
require 'addressable/uri'

class Company < ActiveRecord::Base
  include DomainsCacheable
  include Approvable

  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context
  URL_REGEXP = URI.regexp(%w(http https))

  # notify_associations_about_column_update([:payment_transfers, :payments, :reservations, :listings, :locations], [:instance_id, :partner_id])
  # notify_associations_about_column_update([:reservations, :listings, :locations], [:creator_id, :listings_public])

  has_metadata accessors: [:draft_at, :completed_at]

  attr_accessor :created_payment_transfers, :bank_account_number, :bank_routing_number, :bank_owner_name, :verify_associated

  has_many :approval_requests, as: :owner, dependent: :destroy
  has_many :company_users, dependent: :destroy
  has_many :data_uploads, as: :target
  has_many :instance_clients, as: :client, dependent: :destroy
  has_many :listings, class_name: 'Transactable', inverse_of: :company
  has_many :locations, dependent: :destroy, inverse_of: :company
  has_many :locations_impressions, source: :impressions, through: :locations
  has_many :merchant_accounts, as: :merchantable
  has_many :orders
  has_many :purchases
  has_many :payments
  has_many :payment_transfers, dependent: :destroy
  has_many :photos, through: :listings
  has_many :reservations
  has_many :recurring_bookings
  has_many :offers, inverse_of: :company, dependent: :destroy
  has_many :shipping_profiles
  has_many :users, through: :company_users
  has_many :waiver_agreement_templates, as: :target

  has_one :company_address, class_name: 'Address', as: :entity
  has_one :domain, as: :target, foreign_key: 'target_id', dependent: :destroy
  has_one :theme, as: :owner, foreign_key: 'owner_id', dependent: :destroy

  belongs_to :creator, -> { with_deleted }, class_name: 'User', inverse_of: :created_companies
  belongs_to :instance
  belongs_to :partner
  belongs_to :payments_mailing_address, class_name: 'Address', foreign_key: 'mailing_address_id'

  before_validation :add_default_url_scheme
  before_save :set_creator_address

  validates :name, presence: true
  validates :description, length: { maximum: 250 }
  validates :url, length: { maximum: 250 }
  validates :name, length: { maximum: 50 }
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
  scope :needs_payment_transfer, lambda {
    joins(:payments).merge(Payment.needs_payment_transfer)
  }

  accepts_nested_attributes_for :domain, reject_if: proc { |params| params.delete(:white_label_enabled).to_f.zero? }
  accepts_nested_attributes_for :theme, reject_if: proc { |params| params.delete(:white_label_enabled).to_f.zero? }
  accepts_nested_attributes_for :locations
  accepts_nested_attributes_for :company_address
  accepts_nested_attributes_for :payments_mailing_address
  accepts_nested_attributes_for :approval_requests
  accepts_nested_attributes_for :merchant_accounts, allow_destroy: true, update_only: true

  validates :paypal_email, email: true, allow_blank: true

  after_create :set_external_id

  def email
    super.presence || creator.try(:email)
  end

  def iso_country_code
    iso_country_code = PlatformContext.current.instance.skip_company? ? creator.try(:iso_country_code) : company_address.try(:iso_country_code)
    iso_country_code.presence || instance.default_country_code
  end

  def add_creator_to_company_users
    users << creator unless users.include?(creator)
  end

  def self.xml_attributes
    csv_fields.keys
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
          created_payment_transfers << payment_transfer if possible_payout_not_configured?(payout_payment_gateway)
        end
      end
    end
    # we want to notify company owner (once no matter how many payment transfers have been generated!)
    # that it is possible to make automated payout but he needs to enter credentials via edit company settings
    if mailing_address.blank? && created_payment_transfers.any?
      WorkflowStepJob.perform(WorkflowStep::PayoutWorkflow::NoPayoutOption, id, created_payment_transfers.map(&:id))
    end
  end

  def payout_payment_gateway
    @payment_gateway ||= instance.payout_gateway(iso_country_code, currency)
  end

  def payout_payment_gateways
    instance.payout_gateways(iso_country_code, all_currencies)
  end

  def boarding_payment_gateway
    @boarding_payment_gateway ||= PaymentGateway.where(instance: instance).all.find do |pg|
      pg.supports_currency?(currency) && pg.payout_supports_country?(iso_country_code) && pg.supports_paypal_chain_payments?
    end
  end

  def currency
    @currency ||= all_currencies.first
  end

  def all_currencies
    listings.select('DISTINCT currency').map(&:currency).presence || [instance.default_currency || 'USD']
  end

  def possible_payout_not_configured?(payment_gateway)
    payment_gateway.try(:supports_payout?) && has_verified_merchant_account?(payment_gateway)
  end

  def has_verified_merchant_account?(payment_gateway)
    merchant_accounts.verified_on_payment_gateway(payment_gateway.id).count.zero?
  end

  def possible_payout?
    return false unless payout_payment_gateway
    has_verified_merchant_account?(payout_payment_gateway)
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
      self.url = new_url
    end
  end

  def validate_url_format
    return if url.blank?
    # We parse and normalize with Addressable to make sure we catch unicode domains as well

    parsed = begin Addressable::URI.parse(url)
             rescue Addressable::URI::InvalidURIError
               ''
             end
    normalized = parsed.try(:normalize).to_s

    valid = URL_REGEXP.match(normalized)
    valid &&= begin
                URI.parse(normalized)
              rescue
                false
              end
    errors.add(:url, 'must be a valid URL') unless valid
  end

  def self.csv_fields
    { name: 'Company Name', url: 'Company Website', email: 'Company Email', external_id: 'Company External Id' }
  end

  def rfq_count
    Support::Ticket.for_filter('open').where('target_type = ? AND target_id IN (?)', 'Transactable', listings.pluck(:id)).count
  end

  def mailing_address
    if payments_mailing_address.present?
      payments_mailing_address.address
    else
      self[:mailing_address]
    end
  end

  def missing_payout_information?
    return false unless instance.require_payout?
    listings.without_possible_payout.any?
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
      ActiveSupport::TimeZone::MAPPING.select { |_k, v| v == NearestTimeZone.to(latitude, longitude) }.keys.first || 'UTC'
    else
      creator.try(:time_zone)
    end
  end

  def set_external_id
    update_column(:external_id, "manual-#{id}") if external_id.blank?
  end

  def jsonapi_serializer_class_name
    'CompanyJsonSerializer'
  end
end
