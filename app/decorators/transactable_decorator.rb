class TransactableDecorator < Draper::Decorator
  include Draper::LazyHelpers

  delegate_all

  def user_message_recipient
    administrator
  end

  def user_message_summary(user_message)
    link_to user_message.thread_context.name, location_path(user_message.thread_context.location, user_message.thread_context)
  end

  def price_with_currency(price_name_or_object)
    actual_price = nil
    if price_name_or_object.respond_to?(:fractional)
      actual_price = price_name_or_object
    else
      actual_price = self.send(price_name_or_object)
    end

    self.location.decorate.price_with_currency(actual_price)
  end

  def lowest_price_with_currency(filter_pricing = [])
    listing_price = self.lowest_price_with_type(filter_pricing)
    if listing_price
      periods = {:monthly => 'month', :weekly => 'week', :daily => 'day', :hourly => 'hour'}
      "#{self.price_with_currency(listing_price[0])} <span>/ #{periods[listing_price[1]]}</span>".html_safe
    end
  end

  def actions_allowed?
    !self.transactable_type.action_na
  end

end
