class PaymentGatewaysCountry < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :country
  belongs_to :payment_gateway
end
