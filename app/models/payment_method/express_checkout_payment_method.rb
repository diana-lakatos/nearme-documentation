class PaymentMethod::ExpressCheckoutPaymentMethod < PaymentMethod
  has_many :payment_sources, class_name: 'PaypalAccount', foreign_key: 'payment_method_id'

  def payment_source_type_class
    PaypalAccount
  end

  def name
    "PayPal Express"
  end

end
