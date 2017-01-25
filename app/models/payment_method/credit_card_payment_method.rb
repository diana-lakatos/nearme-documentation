class PaymentMethod::CreditCardPaymentMethod < PaymentMethod
  has_many :payment_sources, class_name: 'CreditCard', foreign_key: 'payment_method_id'

end
