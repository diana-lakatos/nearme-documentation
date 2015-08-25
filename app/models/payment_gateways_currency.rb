class PaymentGatewaysCurrency < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :currency
  belongs_to :payment_gateway
end
