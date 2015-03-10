class BillingAuthorization < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context

  attr_encrypted :token, :payment_gateway_class, key: DesksnearMe::Application.config.secret_token

  serialize :response, Hash

  attr_encrypted :response, key: DesksnearMe::Application.config.secret_token, marshal: true

  belongs_to :reference, polymorphic: true
  validates :payment_gateway_class, presence: true
  validates_presence_of :token, if: lambda { |billing_authorization| billing_authorization.success? }
end
