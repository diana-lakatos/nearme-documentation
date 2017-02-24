class CreditCard < ActiveRecord::Base
  include Encryptable
  include Modelable

  attr_accessor :client, :credit_card_token, :payer

  attr_encrypted :response

  belongs_to :instance_client, -> { with_deleted }
  belongs_to :instance
  has_one :payment_gateway, through: :payment_method
  belongs_to :payment_method, -> { with_deleted }
  has_many :payments, as: :payment_source
  has_many :authorized_payments, -> { authorized }, class_name: 'Payment', as: :payment_source
  has_many :reservations

  before_validation :set_instance_client
  before_create :set_as_default
  before_create :set_mode

  scope :default, -> { where(default_card: true).limit(1) }

  validate :validate_card, on: :create
  validates :instance_client, presence: true

  delegate :expires_at, :last_4, :name, to: :decorator, allow_nil: true

  [:number, :verification_value, :month, :year, :first_name, :last_name].each do |accessor|
    define_method("#{accessor}=") do |attribute|
      instance_variable_set("@#{accessor}", attribute.try(:to_s).try(:strip))
      active_merchant_card.send("#{accessor}=", attribute.try(:to_s).try(:strip))
    end

    define_method(accessor.to_s) do
      active_merchant_card.send(accessor)
    end
  end

  def can_activate?
    success?
  end

  def name
    I18n.t('credit_cards.masked_number', last4: last_4)
  end

  def authorizable?
    true
  end

  def customer_id
    instance_client.try(:customer_id)
  end

  def charge!(amount, options)
    payment_gateway.gateway_authorize(amount, charge_token, options)
  end

  def process!
    return true unless payment_gateway.supports_payment_source_store?
    return true  if success?
    return false if payment_gateway.blank?

    original_response = payment_gateway.store(credit_card_token || active_merchant_card, instance_client)
    self.response = original_response.to_yaml

    if success?
      if instance_client.response.blank?
        instance_client.response ||= response
        instance_client.save!
      end
      true
    else
      errors.add(:base, original_response.params['error'].try('[]', 'message'))
      false
    end
  end

  def set_as_default
    self.default_card = true
  end

  def decorator
    return nil if payment_gateway.nil?
    @decorator ||= case payment_gateway.name
                   when 'Stripe'
                     CreditCard::StripeDecorator.new(self)
                   when 'Stripe Connect'
                     CreditCard::StripeDecorator.new(self)
                   when 'Braintree'
                     CreditCard::BraintreeDecorator.new(self)
                   when 'Braintree Marketplace'
                     CreditCard::BraintreeDecorator.new(self)
                   end
  end

  def token
    decorator.try(:token) if success?
  end

  def success?
    has_response = begin
                   response.present?
                 rescue
                   false
                 end
    if has_response
      !!YAML.load(response).try(&:success?)
    else
      false
    end
  end

  def active_merchant_card
    @active_merchant_card ||= ActiveMerchant::Billing::CreditCard.new
  end

  def to_active_merchant
    token || active_merchant_card
  end

  def active?
    available? && !expired? && (decorator.respond_to?(:active?) ? decorator.active? : true)
  end

  private

  def available?
    success?
  end

  def expired?
    !!expires_at && expires_at < Time.now
  end

  def delete!
    payment_gateway.gateway_delete(instance_client, options)
    true
  end

  def validate_card
    return true if success? || credit_card_token || active_merchant_card.valid?

    errors.add(:base, I18n.t('buy_sell_market.checkout.invalid_cc'))
    active_merchant_card.errors.each do |key, value|
      if value.is_a?(Array)
        errors.add(key, value.flatten.first)
      else
        errors.add(key, value)
      end
    end
    false
  end

  def options
    { credit_card_token: token }
  end

  def set_instance_client
    self.instance_client ||= payment_gateway.instance_clients.where(
      client: payer,  test_mode: test_mode?
    ).first_or_initialize
    true
  end

  def set_mode
    self.test_mode = instance.test_mode?
    true
  end
end
