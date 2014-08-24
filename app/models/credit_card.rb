class CreditCard < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context
  acts_as_paranoid

  attr_encrypted :response, :key => DesksnearMe::Application.config.secret_token, :if => DesksnearMe::Application.config.encrypt_sensitive_db_columns

  belongs_to :instance_client
  belongs_to :instance
  has_many :reservations

  validates_presence_of :gateway_class, :response
  before_create :set_as_default

  scope :default, lambda { where(default_card: true).limit(1) }

  def set_as_default
    self.default_card = true
  end

  def decorator
    return nil if gateway_class.blank?
    @decorator ||= case gateway_class
                   when "Billing::Gateway::Processor::Incoming::Stripe"
                     CreditCard::StripeDecorator.new(self)
                   else
                     raise NotImplementedError.new("Unknown gateway class: #{gateway_class}")
                   end
  end

  def token
    decorator.try(:token)
  end

end

