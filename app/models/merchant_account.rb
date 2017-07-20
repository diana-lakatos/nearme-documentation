# frozen_string_literal: true
class MerchantAccount < ActiveRecord::Base
  include Encryptable

  not_implemented :custom_options

  has_paper_trail
  auto_set_platform_context
  scoped_to_platform_context
  acts_as_paranoid

  attr_encrypted :response, marshal: true

  has_many :webhooks, as: :webhookable, dependent: :destroy
  has_many :payments
  has_many :payment_transfers
  has_one :payment_subscription, dependent: :destroy, as: :subscriber

  # Relates with Company
  belongs_to :merchantable, polymorphic: true
  belongs_to :instance
  belongs_to :payment_gateway

  belongs_to :company, foreign_key: :merchantable_id
  has_many :instance_clients, through: :company

  accepts_nested_attributes_for :payment_subscription, allow_destroy: true

  validates :merchantable_id, :merchantable_type, presence: { unless: ->(ic) { ic.merchantable.present? } }
  validates :payment_gateway, presence: true
  validate :data_correctness

  delegate :supported_currencies, to: :payment_gateway

  scope :verified_on_payment_gateway, ->(payment_gateway_id) { verified.where('merchant_accounts.payment_gateway_id = ?', payment_gateway_id) }
  scope :pending,  -> { where(state: 'pending') }
  scope :verified, -> { where(state: 'verified') }
  scope :failed,   -> { where(state: 'failed') }
  scope :failed,   -> { where(state: 'voided') }
  scope :live, -> { where(test: false) }
  scope :active, -> { where(state: %w(pending verified)) }
  scope :mode_scope, ->(test_mode = PlatformContext.current.instance.test_mode?) { test_mode ? where(test: true) : where(test: false) }
  scope :paypal_express_chain, -> { where(type: 'MerchantAccount::PaypalExpressChainMerchantAccount') }
  scope :for_company, ->(company_id) { where(merchantable_id: company_id) }

  attr_accessor :skip_validation, :redirect_url

  before_create :set_test_mode_if_necessary
  before_create :onboard!
  before_update :update_onboard!, unless: ->(merchant_account) { merchant_account.skip_validation }

  state_machine :state, initial: :pending do
    after_transition any => :verified, do: :set_possible_payout!
    after_transition verified: :failed, do: :unset_possible_payout!

    event :to_pending do
      transition [:verified, :failed] => :pending
    end

    event :verify do
      transition [:pending, :failed] => :verified
    end

    event :failure do
      transition [:pending, :verified] => :failed
    end

    event :void do
      transition [:pending, :verified] => :voided
    end
  end

  TRANSLATED_ERRORS = {
    'US ID numbers must be 9 characters long' => I18n.t('merchant_account.gateway_errors.us_social_security_format')
  }.freeze

  def to_liquid
    @mechant_account_drop ||= MerchantAccountDrop.new(self)
  end

  def data_correctness(*_args)
  end

  def onboard!(*_args)
  end

  def merchant_id
    external_id
  end

  def void!
    # We use update_attribute to prevent validation errors
    self.skip_validation = true
    update_attribute(:state, :voided)
    unset_possible_payout!
  end

  def update_onboard!(*_args)
  end

  def retrieve_account
    payment_gateway.retrieve_account(external_id)
  end

  # Fetch any response attribute
  # in example attribute('legal_entity.personal_id_number_provided')
  # would return true or false based on the response
  def attribute(attribute)
    return unless attribute
    return unless response_object

    response_object_data = response_object
    attribute.split('.').each do |attr|
      response_object_data = response_object_data[attr]
    end

    response_object_data
  end

  def response_object
    return if new_record? || external_id.blank?

    @response_object ||= retrieve_account
  end

  def client
    merchantable
  end

  # @return [Boolean] whether it supports paypal chain payments
  def chain_payments?
    payment_gateway.supports_paypal_chain_payments?
  end

  def to_attr
    self.class.name.underscore.gsub('merchant_account/', '') + '_attributes'
  end

  def partial_location
    "dashboard/company/merchant_accounts/#{payment_gateway.type_name}"
  end

  def payment_subscription_attributes=(payment_subscription_attributes)
    super(payment_subscription_attributes.merge(subscriber: self))
  end

  def supports_currency?(currency)
    payment_gateway.payment_currencies.map(&:iso_code).include?(currency)
  end

  def set_possible_payout!
    if !test? && merchantable && payment_gateway
      transactables = merchantable.listings.where(currency: supported_currencies)
      transactables.update_all(possible_payout: true)
      ElasticBulkUpdateJob.perform Transactable, transactables.map { |listing| [listing.id, { possible_payout: true }] }
    end

    true
  end

  def unset_possible_payout!
    if !test? && merchantable && payment_gateway
      merchantable.listings.update_all(possible_payout: false)
      merchantable.merchant_accounts.live.verified.each(&:set_possible_payout!)
      ElasticBulkUpdateJob.perform Transactable, merchantable.listings.map { |listing| [listing.id, { possible_payout: false }] }
    end
    true
  end

  def redirect_url
    @redirect_url || Rails.application.routes.url_helpers.edit_dashboard_company_payouts_path
  end

  def translate_error_messages
    if try(:errors).try(:messages).try('[]', :base).present?
      errors.messages[:base] = errors.messages[:base].map do |error|
        if TRANSLATED_ERRORS[error]
          TRANSLATED_ERRORS[error]
        else
          error
        end
      end
    end

    true
  end

  private

  def set_test_mode_if_necessary
    self.test = PlatformContext.current.instance.test_mode?
    true
  end
end
