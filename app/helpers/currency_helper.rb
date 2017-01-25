module CurrencyHelper
  def number_to_currency_symbol(currency, price = '0.00', options = {})
    currency ||= PlatformContext.current.instance.default_currency
    options[:unit] = Money::Currency.new(currency).symbol

    options.reverse_merge!(rel: 'tooltip', title: currency)
    content_tag('span', number_to_currency(price, options),  options)
  end

  def currency_symbol_from_code(currency = nil)
    currency ||= PlatformContext.current.instance.default_currency
    Money::Currency.new(currency).symbol
  end

  def currency_content_tag(currency, price = '0.00', el = :span, currency_options = {}, content_tag_options = {})
    currency ||= PlatformContext.current.instance.default_currency
    content_tag_options.reverse_merge!(class: 'total')
    number_to_currency_symbol(currency, content_tag(el.to_sym, price, content_tag_options), currency_options)
  end

  def render_money(money)
    return '' unless money.respond_to?(:to_money)

    instance = PlatformContext.current.instance
    options = {
      symbol: instance.show_currency_symbol,
      with_currency: instance.show_currency_name,
      no_cents_if_whole: instance.no_cents_if_whole
    }
    money = money.to_money
    money.format(options)
  end
end
