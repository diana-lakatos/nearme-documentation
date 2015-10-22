module Payment::PaymentModule

  PaymentMethod::PAYMENT_METHOD_TYPES.each do |pmt|
    define_method("#{pmt}_payment?") { self.payment_method.try(:payment_method_type) == pmt.to_s }
  end

  def payment_methods
    payment_gateways = PlatformContext.current.instance.payment_gateways(self.company.iso_country_code, self.currency)
    if is_free?
      payment_gateways.map(&:active_free_payment_methods)
    else
      payment_gateways.map(&:active_payment_methods)
    end.flatten.uniq
  end

  def payment_method_id=(payment_method_id)
    self.payment_method = PaymentMethod.find(payment_method_id)
  end

  def active_merchant_payment?
    self.payment_method.try(:capturable?)
  end

  def payment_gateway
    @payment_gateway ||= self.payment_method.try(:payment_gateway)
  end
end
