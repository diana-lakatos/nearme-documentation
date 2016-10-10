class TransactableType::PurchaseAction < TransactableType::ActionType
  def available_units
    %w(item)
  end

  def bookable?
    false
  end

  def related_order_class
    'Purchase'
  end
end
