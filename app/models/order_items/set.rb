class OrderItem::Set < OrderItem
  has_many :transactables, through: :transactable_line_items
end
