class LineItem::Additional < LineItem

  def deletable?
    line_itemable.inactive? && self.optional?
  end
end
