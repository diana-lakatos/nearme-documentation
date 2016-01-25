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

  def set_as_default
    self.default_card = true
  end

  def decorator
    @decorator ||= case payment_gateway.name
                   when 'Stripe'
                     CreditCard::StripeDecorator.new(self)
                   when 'Braintree'
                     CreditCard::BraintreeDecorator.new(self)
                   else
                     raise NotImplementedError.new("Unknown gateway class: #{payment_gateway.name}")
                   end
  end

  def token
    decorator.try(:token)
  end

end

