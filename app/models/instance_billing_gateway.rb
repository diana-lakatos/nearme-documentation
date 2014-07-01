class InstanceBillingGateway < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context
  belongs_to :instance
  # attr_accessible :billing_gateway, :currency

  validates :billing_gateway, :currency, presence: true
end
