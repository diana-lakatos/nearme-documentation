class Spree::LineItemDecorator < Draper::Decorator
  include Draper::LazyHelpers
  include MoneyRails::ActionViewExtension

  delegate_all

  MAX_QTY_FOR_SELECT = 30

  def name(target='')
    link_to object.name, product_url(object.product), target: target
  end

  def description
    object.description
  end

  def quantity_form
    select_tag "quantity[#{object.id}]", options_for_select((1..max_qty), object.quantity), style: 'width: 100%'
  end

  def price
    humanized_money_with_symbol(object.price.to_money(Spree::Config.currency))
  end

  def total
    humanized_money_with_symbol(object.total.to_money(Spree::Config.currency))
  end

  def image(target='')
    link_to product_url(object.product), target: target do
      if object.product.variant_images.count > 0
        image_tag object.product.variant_images.first.image.url(:medium)
      else
        image_tag 'placeholders/144x89.gif'
      end
    end
  end

  private

  def max_qty
    max = object.product.master.total_on_hand
    max > MAX_QTY_FOR_SELECT ? MAX_QTY_FOR_SELECT : max
  end
end
