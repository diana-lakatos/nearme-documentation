class Spree::LineItemDecorator < Draper::Decorator
  include Draper::LazyHelpers
  include MoneyRails::ActionViewExtension
  include FeedbackDecoratorHelper

  delegate_all

  MAX_QTY_FOR_SELECT = 15

  def name_with_link(target='')
    unless object.product.deleted?
      link_to object.product.name, product_url(object.product), target: target
    else
      object.product.name
    end
  end

  def description
    object.description ? object.description : ''
  end

  def short_description(chars=90)
    object.description.to_s.truncate chars, separator: ' '
  end

  def quantity_form
    select_tag "quantity[#{object.id}]", options_for_select((1..max_qty), object.quantity)
  end

  def price
    humanized_money_with_symbol(object.price.to_money(Spree::Config.currency))
  end

  def price_in_cents
    single_money.cents
  end

  def total
    humanized_money_with_symbol(object.total.to_money(Spree::Config.currency))
  end

  def image(target='')
    unless object.product.deleted?
      link_to product_url(object.product), target: target do
        if object.product.variant_images.count > 0
          image_tag object.product.variant_images.last.image.url(:medium)
        else
          image_tag 'placeholders/144x89.gif'
        end
      end
    else
      image_tag 'placeholders/144x89.gif'
    end
  end

  def feedback_object
    object
  end

  private

  def max_qty
    max = object.product.master.total_on_hand
    max = max > MAX_QTY_FOR_SELECT ? MAX_QTY_FOR_SELECT : max
    max < 1 ? object.quantity : max
  end
end
