require 'active_merchant/billing/gateways/paypal/paypal_express_response'

class BillingAuthorization < ActiveRecord::Base
  include Encryptable
  auto_set_platform_context
  scoped_to_platform_context

  attr_encrypted :token, :payment_gateway_class
  attr_encrypted :response, :void_response, marshal: true

  serialize :response, Hash

  belongs_to :instance
  belongs_to :reference, polymorphic: true
  belongs_to :payment_gateway

  scope :success, -> { where(success: true) }

  validates_presence_of :token, if: lambda { |billing_authorization| billing_authorization.success? }

  def void!
    return if void_at.present?
    self.void_response = billing_gateway.void(self)
    touch(:void_at)
  end

  def billing_gateway
    if @billing_gateway.nil?
      @billing_gateway = payment_gateway
      @billing_gateway.force_mode(payment_gateway_mode)
    end
    @billing_gateway
  end
end

