class RecurringBooking::SubscriptionPriceCalculator
  attr_reader :subscription

  def initialize(subscription)
    @subscription = subscription
  end

  def subtotal_amount
    Money.new(@subscription.quantity * @subscription.listing.price_for_subscription(@subscription.interval), @subscription.currency)
  end

  def total_amount
    subtotal_amount + @subscription.service_fee_amount_guest + @subscription.service_additional_charges
  end
end
