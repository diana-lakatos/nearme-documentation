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
  belongs_to :payment
  belongs_to :user

  scope :success, -> { where(success: true) }

  validates_presence_of :token, if: ->(billing_authorization) { billing_authorization.success? }

  def to_liquid
    @billing_authorization_drop ||= BillingAuthorizationDrop.new(self)
  end
end
