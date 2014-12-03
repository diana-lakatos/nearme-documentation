class Payment::ServiceFeeCalculator
  def initialize(amount, guest_fee_percent = BigDecimal(0), host_fee_percent = BigDecimal(0))
    @amount = amount
    @guest_fee_percent = guest_fee_percent
    @host_fee_percent = host_fee_percent
  end

  def service_fee_guest
    @amount * @guest_fee_percent / BigDecimal(100)
  end

  def service_fee_host
    @amount * @host_fee_percent / BigDecimal(100)
  end
end
