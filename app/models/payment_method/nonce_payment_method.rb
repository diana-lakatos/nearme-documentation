# frozen_string_literal: true
class PaymentMethod::NoncePaymentMethod < PaymentMethod
  has_many :payment_sources, class_name: 'PaypalAccount', foreign_key: 'payment_method_id'
  def name
    "Braintree PayPal"
  end
end
