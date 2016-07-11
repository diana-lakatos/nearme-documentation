class TransactableType::SubscriptionBooking < TransactableType::ActionType

  validates :pricings, presence: true, if: :enabled?
  validates_associated :pricings

  def available_units
    %w(subscription_day subscription_month)
  end

end
