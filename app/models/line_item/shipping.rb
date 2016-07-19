class LineItem::Shipping < LineItem

  # Used for summary sorting
  def invoice_position
    2
  end

end
