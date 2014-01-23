class Company < ActiveRecord::Base
  has_paper_trail
  URL_REGEXP = URI::regexp(%w(http https))

  attr_accessible :creator_id, :deleted_at, :description, :url, :email, :name,
    :mailing_address, :paypal_email, :industry_ids, :locations_attributes,
    :domain_attributes, :theme_attributes, :instance_id, :white_label_enabled,
    :listings_public, :partner_id, :bank_account_number, :bank_routing_number, :bank_owner_name

  attr_accessor :created_payment_transfers, :bank_account_number, :bank_routing_number, :bank_owner_name

  belongs_to :creator, class_name: "User", inverse_of: :created_companies
  belongs_to :instance
  belongs_to :partner

  has_many :company_users, dependent: :destroy
  has_many :users, :through => :company_users

  has_many :locations,
    dependent: :destroy,
    inverse_of: :company

  has_many :listings,
    through: :locations

  has_many :reservations,
    through: :listings

  has_many :reservation_charges,
    through: :reservations

  has_many :payment_transfers

  has_many :company_industries
  has_many :industries, :through => :company_industries

  has_one :domain, :as => :target, :dependent => :destroy
  has_one :theme, :as => :owner, :dependent => :destroy

  has_many :locations_impressions,
    :source => :impressions,
    :through => :locations do
      def for_instance(instance)
        location_ids = proxy_association.owner.locations.for_instance(instance).pluck(:id)
        where(:impressionable_id => location_ids)
      end
    end

    has_many :instance_clients, :as => :client, :dependent => :destroy

    before_validation :add_default_url_scheme

    after_save :notify_user_about_change
    after_destroy :notify_user_about_change
    before_save :create_bank_account_in_balanced, :if => lambda { |c| c.bank_account_number.present? && c.bank_routing_number.present? && c.bank_owner_name.present? }

    validates_presence_of :name, :instance_id
    validates_presence_of :industries, :if => proc { |c| c.instance.present? && c.instance.is_desksnearme? && !c.instance.skip_company? }
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
      joins(:reservation_charges).merge(
        ReservationCharge.needs_payment_transfer
      ).uniq
    }

    acts_as_paranoid

    accepts_nested_attributes_for :domain, :reject_if => proc { |params| params.delete(:white_label_enabled).to_f.zero? }
    accepts_nested_attributes_for :theme, reject_if: proc { |params| params.delete(:white_label_enabled).to_f.zero? }
    accepts_nested_attributes_for :locations

    def notify_user_about_change
      creator.try(:touch)
    end

    def add_creator_to_company_users
      unless users.include?(creator)
        users << creator 
      end
    end

    def self.xml_attributes
      [:name, :description, :email]
    end

    # Schedules a new payment transfer for current outstanding payments for each
    # of the currency payments recieved by the Company.
    def schedule_payment_transfer
      self.created_payment_transfers = []
      transaction do
        charges = reservation_charges.needs_payment_transfer
        charges.group_by(&:currency).each do |currency, charges|
          payment_transfer = payment_transfers.create!(
            reservation_charges: charges
          )
          self.created_payment_transfers << payment_transfer if payment_transfer.possible_automated_payout_not_supported?
        end
      end
      # we want to notify company owner (once no matter how many payment transfers have been generated!) 
      # that it is possible to make automated payout but he needs to enter credentials via edit company settings
      if mailing_address.blank? && self.created_payment_transfers.any?
        CompanyMailer.enqueue.notify_host_of_no_payout_option(self)
        CompanySmsNotifier.notify_host_of_no_payout_option(self).deliver
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
      bank_account_number.to_s[-4, -1]
    end

    def current_instance_client(instance)
      self.instance_clients.where(:instance_id => instance.id).first
    end

    def to_liquid
      CompanyDrop.new(self)
    end

    private

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

    def create_bank_account_in_balanced
      Billing::Gateway::BalancedProcessor.create_customer_with_bank_account(self)
      Rails.logger.debug "all good"
    rescue Balanced::BadRequest => e
      Rails.logger.debug "error - #{e.message}"
      fields = { '[bank_code]' => :bank_routing_number, '[account_number]' => :bank_account_number}
      fields.each do |balanced_field, our_form_field|
        if e.message.include?(balanced_field)
          errors.add(our_form_field, e.message.split("#{balanced_field} - ").last.split(' Your request id is ').first)
        end
      end
      if errors.empty?
        errors.add(:bank_account_form,  e.message.split(" - ").last.split(' Your request id is ').first)
      end
      false
    end

end
