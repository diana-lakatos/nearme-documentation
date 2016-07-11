class RecurringBooking::SubscriptionPriceCalculator
  attr_reader :subscription

  def initialize(subscription)
    @subscription = subscription
    @pricing = @subscription.transactable_pricing
  end

  def subtotal_amount
    Money.new(@subscription.quantity * @pricing.price, @subscription.currency)
  end

  def total_amount
    subtotal_amount + @subscription.service_fee_amount_guest + @subscription.service_additional_charges
  end
end
