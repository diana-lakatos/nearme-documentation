module CurrencyHelper

  def number_to_currency_symbol(currency, price = '0.00', options = {})
    currency ||= 'USD'
    options[:unit] = Money::Currency.new(currency).symbol 
    content_tag('span', number_to_currency(price, options), :rel => 'tooltip', :title => currency)
  end

  def currency_content_tag(currency, price = "0.00", el = :span, currency_options = {}, content_tag_options = {} )
    currency ||= 'USD'
    content_tag_options.reverse_merge!({ :class => "total" })
    number_to_currency_symbol(currency, content_tag(el.to_sym, price, content_tag_options), currency_options) 
  end

  def humanized_money_with_cents_and_symbol(money)
    return "" unless money.respond_to?(:to_money)

    money = money.to_money
    money.format(:symbol => true)
  end

end
