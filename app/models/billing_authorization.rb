class BillingAuthorization < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context

  attr_encrypted :token, :payment_gateway_class, :key => DesksnearMe::Application.config.secret_token
  belongs_to :reference, polymorphic: true
  validates :token, :payment_gateway_class, presence: true
end
