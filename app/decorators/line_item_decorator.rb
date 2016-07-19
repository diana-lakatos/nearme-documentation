class LineItemDecorator < Draper::Decorator
  include Draper::LazyHelpers
  include MoneyRails::ActionViewExtension
  include FeedbackDecoratorHelper
  include ActionView::Helpers::UrlHelper

  delegate_all

  MAX_QTY_FOR_SELECT = 15

  def name_with_link(target='')
    return name unless line_item_source.is_a?(Transactable)

    unless line_item_source.deleted?
      link_to line_item_source.name, line_item_source.try(:decorate).try(:show_url), target: target
    else
      line_item_source.name
    end
  end

  def description
    object.description ? object.description : ''
  end

  def short_description(chars=90)
    object.description.to_s.truncate chars, separator: ' '
  end

  def quantity_form
    select_tag "quantity[#{object.id}]", options_for_select((1..max_qty), object.quantity.to_i)
  end

  def unit_price
    humanized_money_with_symbol(object.unit_price.to_money(currency))
  end

  def gross_price
    humanized_money_with_symbol(object.gross_price.to_money(currency))
  end

  def net_price
    humanized_money_with_symbol(object.net_price.to_money(currency))
  end

  def total_price
    humanized_money_with_cents_and_symbol(object.total_price.to_money(currency))
  end

  def price_in_cents
    single_money.cents
  end

  def total
    humanized_money_with_symbol(object.total.to_money(Spree::Config.currency))
  end

  def image(target='')
    return '' unless object.respond_to?(:transactable)
    unless object.transactable.deleted?
      link_to object.transactable.try(:decorate).try(:show_url), target: target do
        if object.transactable.has_photos?
          image_tag object.transactable.decorate.photos_metadata.try(:first).try(:[], :space_listing), width: 144, height: 89
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
    return 1 unless object.respond_to?(:line_item_source)

    max = object.line_item_source.quantity
    max = max > MAX_QTY_FOR_SELECT ? MAX_QTY_FOR_SELECT : max
    max < 1 ? object.quantity : max
  end
end
