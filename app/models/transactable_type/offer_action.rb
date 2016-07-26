class TransactableType::OfferAction < TransactableType::ActionType

  def available_units
    %w(item)
  end

  def bookable?
    false
  end

  def related_order_class
    'Offer'
  end

end