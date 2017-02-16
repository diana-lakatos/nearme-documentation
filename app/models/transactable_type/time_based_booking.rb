class TransactableType::TimeBasedBooking < TransactableType::ActionType
  validates :pricings, presence: true, if: :enabled?
  validates_associated :pricings

  validates_numericality_of :minimum_booking_minutes, greater_than_or_equal_to: 15

  def available_units
    %w(hour day day_month night night_month)
  end
end
