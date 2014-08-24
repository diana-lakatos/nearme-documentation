class InstanceClient < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context
  acts_as_paranoid

  attr_encrypted :balanced_user_id, :balanced_credit_card_id, :response, :key => DesksnearMe::Application.config.secret_token, :if => DesksnearMe::Application.config.encrypt_sensitive_db_columns

  belongs_to :client, :polymorphic => true
  belongs_to :instance
  has_many :credit_cards

  validates_presence_of :client_id, :client_type, :unless => lambda { |ic| ic.client.present? }

  def credit_card
    credit_cards.default
  end

  def decorator
    return nil if gateway_class.blank?
    @decorator ||= case gateway_class
                   when "Billing::Gateway::Processor::Incoming::Stripe"
                     InstanceClient::StripeDecorator.new(self)
                   else
                     raise NotImplementedError.new("Unknown gateway class: #{gateway_class}")
                   end
  end

  def customer_id
    decorator.try(:customer_id)
  end

end
