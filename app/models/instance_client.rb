class InstanceClient < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context
  acts_as_paranoid

  attr_encrypted :balanced_user_id, :balanced_credit_card_id, :response, :key => DesksnearMe::Application.config.secret_token, :if => DesksnearMe::Application.config.encrypt_sensitive_db_columns

  belongs_to :client, :polymorphic => true
  belongs_to :instance
  has_many :credit_cards
  before_save :clear_decorator, if: lambda { |ic| ic.encrypted_response_changed? }

  validates_presence_of :client_id, :client_type, :unless => lambda { |ic| ic.client.present? }

  def credit_card
    credit_cards.default
  end

  def decorator
    @decorator ||= case gateway_class
                   when "Billing::Gateway::Processor::Incoming::Stripe"
                     InstanceClient::StripeDecorator.new(self)
                   when "Billing::Gateway::Processor::Incoming::Braintree"
                     InstanceClient::BraintreeDecorator.new(self)
                   when nil
                     nil
                   else
                     raise NotImplementedError.new("Unknown gateway class: #{gateway_class}")
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

