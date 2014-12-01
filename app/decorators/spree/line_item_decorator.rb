class Spree::LineItemDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  def name
    link_to object.name, product_url(object.product)
  end

  def description

  end

  def quantity
    text_field_tag "quantity[#{object.id}]", object.quantity, class: 'numeric integer input-mini', type: 'number'
  end
end
