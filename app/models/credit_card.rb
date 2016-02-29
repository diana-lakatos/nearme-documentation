class CreditCard < ActiveRecord::Base
  include Encryptable

  auto_set_platform_context
  scoped_to_platform_context
  acts_as_paranoid

  attr_encrypted :response

  belongs_to :instance_client
  belongs_to :instance
  belongs_to :payment_gateway
  has_many :reservations

  before_create :set_as_default

  scope :default, lambda { where(default_card: true).limit(1) }

  validate :validate_card

  delegate :customer_id, to: :instance_client, allow_nil: true

  before_create :store!

  [:number, :verification_value, :month, :year, :first_name, :last_name].each do |accessor|
    define_method("#{accessor}=") do |attribute|
      instance_variable_set("@#{accessor}", attribute.try(:to_s).try(:strip))
      active_merchant_card.send("#{accessor}=", attribute.try(:to_s).try(:strip))
    end

    define_method("#{accessor}") do
      active_merchant_card.send(accessor)
    end
  end

  def set_as_default
    self.default_card = true
  end

  def decorator
    @decorator ||= case payment_gateway.name
                   when 'Stripe'
                     CreditCard::StripeDecorator.new(self)
                   when 'Braintree'
                     CreditCard::BraintreeDecorator.new(self)
                   end
  end

  def token
    if success?
      decorator.try(:token)
    else
      nil
    end
  end

  def success?
    if response
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

  private

  def store!
    return true  if success?
    return false if payment_gateway.blank?
    return false if instance_client.blank?

    # We need to parse response respectively for each PaymentGateway
    decorator.response = payment_gateway.store(active_merchant_card, instance_client)

    if success?
      self.instance_client.save!
      true
    else
      errors.add(:base, I18n.t('reservations_review.errors.internal_payment'))
      false
    end
  end

  def validate_card
    return true if success?

    unless active_merchant_card.valid?
      errors.add(:base, I18n.t('buy_sell_market.checkout.invalid_cc'))
      active_merchant_card.errors.each do |key,value|
        errors.add(key, value)
      end
      false
    else
      true
    end
  end

end

