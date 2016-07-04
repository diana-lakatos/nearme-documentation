class TransactableType::NoActionBooking < TransactableType::ActionType

  def available_units
    []
  end

  def bookable?
    false
  end

  def is_no_action?
    true
  end

  def allow_no_action
    true
  end

  alias_method :allow_no_action?, :allow_no_action

end