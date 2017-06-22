# frozen_string_literal: true
class BankAccount < ActiveRecord::Base
  include Encryptable
  include Modelable

  FAILED_STATES = %w(verification_failed errored).freeze
  SUCCESS_STATES = %w(new verified validated).freeze

  attr_accessor :public_token, :account_id, :token, :payer
  attr_accessor :country, :currency, :routing_number, :account_number, :account_holder_name, :account_holder_type
  attr_accessor :verification_amount_1, :verification_amount_2

  attr_encrypted :response
  attr_encrypted :external_id

  belongs_to :instance_client, -> { with_deleted }
  belongs_to :instance
  belongs_to :payment_method, -> { with_deleted }
  has_one :payment_gateway, through: :payment_method
  has_many :payments, as: :payment_source

  before_validation :set_mode

  validates :instance_client, presence: true

  delegate :customer_id, to: :instance_client
  delegate :plaid_configured?, to: :payment_method

  def name
    I18n.t('payment_source.masked_number_with_bank_name', last4: last_4, bank: bank_name)
  end

  def authorizable?
    false
  end

  def process!
    (external_id || new_customer_external_id).present? && success?
  end

  def to_active_merchant
    external_id
  end
  alias token to_active_merchant

  def instance_client
    @instance_client ||= super || existing_instance_client || new_instance_client
  end

  def new_instance_client
    build_instance_client(client: payer, test_mode: test_mode?, payment_gateway: payment_gateway)
  end

  def verified?
    status == 'verified'
  end

  def failed?
    FAILED_STATES.include?(status)
  end

  def success?
    SUCCESS_STATES.include?(status)
  end

  def state
    status
  end

  def last_4
    last4
  end

  def can_activate?
    external_id.present? && success?
  end

  def verify!
    response = find.verify(amounts: [verification_amount_1.to_i, verification_amount_2.to_i])
    update_attribute(:status, response.status)
    true
  rescue => e
    errors.add(:base, e.message)
    false
  end

  def find
    customer = instance_client.find
    customer.sources.retrieve(external_id)
  end

  def to_liquid
    @bank_account_drop ||= BankAccountDrop.new(self)
  end

  private

  def new_customer_external_id
    if plaid_configured? && public_token.present? && account_id.present?
      create_account_with_plaid
    elsif public_token.present?
      create_source(public_token)
    else
      errors.add(:base, :incrrect_account)
    end

    external_id
  end

  def existing_instance_client
    existing_instance_client = payment_gateway.instance_clients.where(
      client: payer,
      test_mode: test_mode?
    ).first

    # As PaymentGatway can be switched
    # at we need to verify if that customer exists withing confifured PaymentGateway
    return unless existing_instance_client.try(:find)
    self.instance_client = existing_instance_client
  end

  def create_account_with_plaid
    exchange_response = payment_method.plaid_client.item.public_token.exchange(public_token)
    stripe_response = payment_method.plaid_client.processor.stripe.bank_account_token.create(exchange_response['access_token'], account_id)
    bank_account_token = stripe_response['stripe_bank_account_token']
    create_source(bank_account_token)
  end

  def create_source(token)
    if token.present? && (customer_response = instance_client.try(:find))
      begin
        bank_account_response = customer_response.sources.create(source: token)
      rescue => e
        errors.add(:base, e.message)
        return false
      end
    else
      customer_response = payment_gateway.create_customer(token, payer.email)
      instance_client.response ||= customer_response.to_yaml
      instance_client.save!
      customer_response = PaymentGateway::Response::Stripe::Customer.new(customer_response)
    end

    set_attributes_from_customer_response(customer_response, bank_account_response)
  end

  def set_attributes_from_customer_response(customer_response, bank_account_response = nil)
    self.response = bank_account_response || customer_response.bank_accounts.last.try(:response)
    self.last4 = response.last4
    self.status = response.status
    self.bank_name = response.bank_name
    self.external_id = response.id
    save!

    send_workflow_for(state)
  end

  def send_workflow_for(state)
    case state
    when 'verified'
      WorkflowStepJob.perform(WorkflowStep::PaymentGatewayWorkflow::BankAccountVerified, id)
    when 'new'
      WorkflowStepJob.perform(WorkflowStep::PaymentGatewayWorkflow::BankAccountPending, id)
    end
  end

  def set_mode
    self.test_mode = payment_gateway.test_mode?
    true
  end
end
