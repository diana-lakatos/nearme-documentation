class RecurringBooking::SubscriptionPriceCalculator
  attr_reader :subscription

  def initialize(subscription)
    @subscription = subscription
  end

  def subtotal_amount
    price_for_subscription = @subscription.listing.price_for_subscription(@subscription.interval)
    # This can happen in rare instances if the listing was initially a subscription based one at the
    # time the booking was made but was later changed to something else; price should probably
    # be moved to reservation/recurring booking; for now this is a quick fix allowing listings to be
    # deleted (otherwise deleting listings would fail because price_for_subscription is nil)
    price_for_subscription = 0 if price_for_subscription.blank?
    Money.new(@subscription.quantity * price_for_subscription, @subscription.currency)
  end

  def total_amount
    subtotal_amount + @subscription.service_fee_amount_guest + @subscription.service_additional_charges
  end
end
