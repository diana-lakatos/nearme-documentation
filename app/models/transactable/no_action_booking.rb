class Transactable::NoActionBooking < Transactable::ActionType
  has_one :pricing, as: :action
  delegate :price, :unit, to: :pricing, allow_nil: true

  def is_no_action?
    false
  end

  def is_free_booking?
    true
  end

  def no_action
    !action_rfq?
  end

  alias_method :no_action?, :no_action
end
