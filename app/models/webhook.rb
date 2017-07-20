# frozen_string_literal: true
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
    event :failed do transition [:failed, :pending, :archived] => :failed; end
    event :success do transition [:pending, :failed] => :success; end
  end

  def response_object
    YAML.load(response || '') || {}
  end

  def show_event
    event.to_yaml.gsub(' ', '&nbsp;&nbsp;').gsub("\n", '<br/>')
  rescue
    "Can't fetch this event"
  end

  def set_payment_gateway_mode
    self.payment_gateway_mode = (livemode? ? PaymentGateway::LIVE_MODE : PaymentGateway::TEST_MODE)
  end

  def webhook_type
    nil
  end

  def process_error(error_message, should_raise: false)
    self.error = error_message.to_s
    failed!
    should_raise ? raise(error_message) : false
  end
end
