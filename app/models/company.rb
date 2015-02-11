class Company < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context
  URL_REGEXP = URI::regexp(%w(http https))
  has_metadata :accessors => [:industries_metadata]

  notify_associations_about_column_update([:payment_transfers, :payments, :reservations, :listings, :locations], [:instance_id, :partner_id])
  notify_associations_about_column_update([:reservations, :listings, :locations], [:creator_id, :listings_public])

  attr_accessor :created_payment_transfers, :bank_account_number, :bank_routing_number, :bank_owner_name, :verify_associated

  belongs_to :creator, class_name: "User", inverse_of: :created_companies
  belongs_to :instance
  belongs_to :partner
  has_many :company_users, dependent: :destroy
  has_many :users, :through => :company_users
  has_many :locations, dependent: :destroy, inverse_of: :company
  has_many :listings, class_name: 'Transactable', inverse_of: :company
  has_many :photos, through: :listings
  has_many :products, class_name: 'Spree::Product', inverse_of: :company, dependent: :destroy
  has_many :products_images, through: :products, source: :variant_images

  has_many :properties, class_name: 'Spree::Property', dependent: :destroy
  has_many :prototypes, class_name: 'Spree::Prototype', dependent: :destroy
  has_many :option_types, class_name: 'Spree::OptionType', dependent: :destroy
  has_many :order_line_items, class_name: 'Spree::LineItem'
  has_many :orders, class_name: 'Spree::Order'
  has_many :taxonomies, class_name: 'Spree::Taxonomy', dependent: :destroy
  has_many :tax_categories, class_name: 'Spree::TaxCategory', dependent: :destroy
  has_many :shipping_categories, class_name: 'Spree::ShippingCategory', dependent: :destroy
  has_many :shipping_methods, class_name: 'Spree::ShippingMethod', dependent: :destroy
  has_many :taxons, class_name: 'Spree::Taxon', dependent: :destroy
  has_many :stock_locations, class_name: 'Spree::StockLocation', dependent: :destroy
  has_many :variants, class_name: 'Spree::Variant', dependent: :destroy
  has_many :zones, class_name: 'Spree::Zone', dependent: :destroy

  has_many :reservations
  has_many :payments
  has_many :order_charges, through: :orders, source: :near_me_payments
  has_many :payment_transfers, :dependent => :destroy
  has_many :company_industries, :dependent => :destroy
  has_many :industries, :through => :company_industries
  has_many :waiver_agreement_templates, as: :target
  has_many :approval_requests, as: :owner, dependent: :destroy
  has_one :domain, :as => :target, foreign_key: 'target_id', :dependent => :destroy
  has_one :theme, :as => :owner, foreign_key: 'owner_id', :dependent => :destroy

  has_many :locations_impressions, :source => :impressions, :through => :locations
  has_many :instance_clients, :as => :client, :dependent => :destroy
  has_many :data_uploads, as: :target
  has_one :company_address, class_name: 'Address', as: :entity
  delegate :address, :address2, :formatted_address, :postcode, :suburb, :city, :state, :country, :street, :address_components,
   :latitude, :longitude, :state_code, :iso_country_code, to: :company_address, allow_nil: true

  before_validation :add_default_url_scheme

  before_save :create_bank_account_in_balanced!, :if => lambda { |c| c.bank_account_number.present? || c.bank_routing_number.present? || c.bank_owner_name.present? }

  validates_presence_of :name
  validates_presence_of :industries, :if => proc { |c| c.instance.present? && c.instance.has_industries? && !c.instance.skip_company? }
  validates_length_of :description, :maximum => 250
  validates_length_of :name, :maximum => 50
  validates :email, email: true, allow_blank: true
  validate :validate_url_format

  delegate :service_fee_guest_percent, to: :instance, allow_nil: true
  delegate :service_fee_host_percent, to: :instance, allow_nil: true

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
  accepts_nested_attributes_for :approval_requests
  accepts_nested_attributes_for :products, :shipping_methods, :shipping_categories, :stock_locations

  validates_associated :shipping_methods, :if => :verify_associated
  validates_associated :shipping_categories, :if => :verify_associated
  validates_associated :products, :if => :verify_associated
  validates_associated :stock_locations, :if => :verify_associated

  validates :paypal_email, email: true, allow_blank: true

  after_create :add_company_to_partially_created_shipping_categories

  def add_company_to_partially_created_shipping_categories
    partial_categories = Spree::ShippingCategory.where(:user_id => self.creator_id, :company_id => nil)
    partial_categories.each do |partial_category|
      partial_category.update_attribute(:company_id, self.id)
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
      charges_without_payment_transfer.group_by(&:currency).each do |currency, charges|
        payment_transfer = payment_transfers.create!(
          payments: charges
        )
        self.created_payment_transfers << payment_transfer if payment_transfer.possible_automated_payout_not_supported?
      end
    end
    # we want to notify company owner (once no matter how many payment transfers have been generated!)
    # that it is possible to make automated payout but he needs to enter credentials via edit company settings
    if mailing_address.blank? && self.created_payment_transfers.any?
      WorkflowStepJob.perform(WorkflowStep::PayoutWorkflow::NoPayoutOption, self.id, self.created_payment_transfers)
    end
  end

  def to_balanced_params
    {
      name: name,
      email: email.presence || creator.try(:email),
      phone: creator.try(:phone)
    }
  end

  def balanced_bank_account_details
    {
      :account_number => bank_account_number,
      :bank_code => bank_routing_number,
      :name => bank_owner_name,
      :type => 'checking'
    }
  end

  def last_four_digits_of_bank_account
    bank_account_number.to_s[-4, 4]
  end

  def to_liquid
    CompanyDrop.new(self)
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

  # TODO: Exctract to another object
  def create_bank_account_in_balanced!
    [:bank_account_number, :bank_routing_number, :bank_owner_name].each do |mandatory_field|
      errors.add(mandatory_field, 'cannot be blank') if self.send(mandatory_field).blank?
    end
    if errors.any?
      false
    else
      begin
        # when more processors will support ACH, we will want to use some kind of wrapper instead of calling BalancedProcessor directly
        Billing::Gateway::Processor::Outgoing::Balanced.create_customer_with_bank_account!(self)
      rescue Balanced::Unauthorized => e
        errors.add(:bank_account_form, 'We could not validate your bank account details at this time. Please try again later.')
        ExceptionTracker.track_exception(e)
        false
      end
    end
  rescue Balanced::BadRequest => e
    { '[bank_code]' => :bank_routing_number, '[account_number]' => :bank_account_number}.each do |balanced_field, our_form_field|
      if e.message.include?(balanced_field)
        errors.add(our_form_field, e.message.split("#{balanced_field} - ").last.split(' Your request id is ').first)
      end
    end
    if errors.empty?
      if e.message.include?('Routing number is invalid')
        errors.add(:bank_routing_number, 'is invalid')
      else
        errors.add(:bank_account_form,  e.message.split(" - ").last.split(' Your request id is ').first)
      end
    end
    false
  rescue RuntimeError => e
    errors.add(:bank_account_form, 'Invalidating previous bank account failed. Please try again later.')
    false
  end

  def self.csv_fields
    { name: 'Company Name', url: 'Company Website', email: 'Company Email', external_id: 'Company External Id' }
  end

  def approval_request_templates
    @approval_request_templates ||= PlatformContext.current.instance.approval_request_templates.for("Company")
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

end
