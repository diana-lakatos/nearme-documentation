class Transactable::SubscriptionBooking < Transactable::ActionType
  validates :pricings, presence: true, if: :enabled?
  validates_associated :pricings, if: :enabled?

  def booking_module_options
    super.merge(minimum_date: Time.now.in_time_zone(time_zone).to_date,
                maximum_date: Time.now.in_time_zone(time_zone).advance(years: 1).to_date,
                pricings: Hash[pricings.map { |pricing| [pricing.id, { price: pricing.price.cents }] }])
  end

  def price_calculator(order)
    RecurringBooking::SubscriptionPriceCalculator.new(order)
  end
end
