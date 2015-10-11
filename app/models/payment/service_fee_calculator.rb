class Payment::ServiceFeeCalculator
  def initialize(amount, args = {})
    @amount = amount
    @guest_fee_percent = args[:guest_fee_percent] || BigDecimal(0)
    @host_fee_percent = args[:host_fee_percent] || BigDecimal(0)
    @additional_charges = args[:additional_charges]
  end

  def service_fee_guest
    @amount * (@guest_fee_percent / BigDecimal(100)) + additional_charges_amount
  end

  # Returns the pure service fee without any additional charges
  def service_fee_guest_wo_ac
    @amount * @guest_fee_percent / BigDecimal(100)
  end

  def service_fee_host
    @amount * @host_fee_percent / BigDecimal(100)
  end

  # Returns the total price of all the additional charges that were applied to the reservation
  def additional_charges_amount
    return @additional_charges.collect(&:amount).sum if @additional_charges.present?

    mandatory_charges = PlatformContext.current.instance.additional_charge_types.mandatory_charges
    mandatory_charges.collect(&:amount).sum
  end
end
