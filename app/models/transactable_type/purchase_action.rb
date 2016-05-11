class TransactableType::PurchaseAction < TransactableType::ActionType

  def available_units
    %w(item)
  end

  def bookable?
    false
  end

end