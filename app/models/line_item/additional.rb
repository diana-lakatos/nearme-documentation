class LineItem::Additional < LineItem

  before_save :set_receiver

  def deletable?
    line_itemable.inactive? && self.optional?
  end

  private

  def set_receiver
    self.receiver ||= line_item_source.try(:commission_receiver) || 'host'
  end

end
