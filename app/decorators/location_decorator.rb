class LocationDecorator < Draper::Decorator
  include Draper::LazyHelpers

  delegate_all

  def price_with_currency(price)
    currency = self.try(:currency) || 'USD'
    money_without_cents_and_with_symbol(Money.new(price.try(:fractional), currency))
  end

  def lowest_price_with_currency(filter_pricing = [])
    listing_price = self.lowest_price(filter_pricing)
    if listing_price
      periods = {:monthly => 'month', :weekly => 'week', :daily => 'day', :hourly => 'hour'}
      "From <span>#{self.price_with_currency(listing_price[0])}</span> / #{periods[listing_price[1]]}".html_safe
    end
  end

end

