class TransactableType::EventBooking < TransactableType::ActionType

  has_one :schedule, as: :scheduable, dependent: :destroy
  has_one :pricing, as: :action
  accepts_nested_attributes_for :schedule

  validates :pricings, presence: true, if: :enabled?
  validates_associated :pricings

  def available_units
    %w(event)
  end

end