class InstanceClient < ActiveRecord::Base
  include Encryptable
  auto_set_platform_context
  scoped_to_platform_context
  acts_as_paranoid

  attr_encrypted :response

  belongs_to :client, :polymorphic => true
  belongs_to :instance
  belongs_to :payment_gateway

  has_many :credit_cards
  before_save :clear_decorator, if: lambda { |ic| ic.encrypted_response_changed? }

  validates_presence_of :client_id, :client_type, :unless => lambda { |ic| ic.client.present? }

  def credit_card
    credit_cards.default
  end

  def decorator
    @decorator ||= case payment_gateway.name
                   when 'Stripe'
                     InstanceClient::StripeDecorator.new(self)
                   when 'Braintree'
                     InstanceClient::BraintreeDecorator.new(self)
                   when nil
                     nil
                   else
                     raise NotImplementedError.new("Unknown gateway class: #{payment_gateway.name}")
                   end
  end

  def customer_id
    decorator.try(:customer_id)
  end

  private

  def clear_decorator
    @decorator = nil
  end

end

