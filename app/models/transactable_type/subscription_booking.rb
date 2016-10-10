class TransactableType::SubscriptionBooking < TransactableType::ActionType
  validates :pricings, presence: true, if: :enabled?
  validates_associated :pricings

  def available_units
    %w(subscription_day subscription_month)
  end

  def can_be_free?
    false
  end

  def related_order_class
    'RecurringBooking'
  end
end
