class Spree::LineItemDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  MAX_QTY_FOR_SELECT = 30

  def name
    link_to object.name, product_url(object.product)
  end

  def description

  end

  def quantity
    select_tag "quantity[#{object.id}]", options_for_select((1..max_qty), object.quantity), style: 'width: 100%'
  end

  private

  def max_qty
    max = object.product.master.total_on_hand
    max > MAX_QTY_FOR_SELECT ? MAX_QTY_FOR_SELECT : max
  end
end
