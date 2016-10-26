class Webhook < ActiveRecord::Base
  include Encryptable

  auto_set_platform_context
  scoped_to_platform_context
  acts_as_paranoid

  attr_encrypted :response, marshal: true

  belongs_to :webhookable, polymorphic: true
  belongs_to :payment_gateway
  belongs_to :merchant_account
  belongs_to :instance

  before_create :set_payment_gateway_mode

  state_machine :state, initial: :pending do
    event :mark_as_failed do transition [:failed, :pending, :archived] => :failed; end
    event :archive do transition [:pending, :failed] => :archived; end
  end

  # We use params method only to display saved YAML webhook request
  # Use event method to fetch any webhook information
  def params
    YAML.load(response || '') || {}
  end

  def set_payment_gateway_mode
    self.payment_gateway_mode = (livemode? ? 'live' : 'test')
  end

  def webhook_type
    nil
  end
end
