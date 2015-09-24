Spree::Money.class_eval do

  def initialize(amount, options={})
    @money = Monetize.parse([amount, (options[:currency] || Spree::Config[:currency])].join)
    @options = {
      symbol_position:     Spree::Config[:currency_symbol_position].to_sym,
      decimal_mark:        Spree::Config[:currency_decimal_mark],
      thousands_separator: Spree::Config[:currency_thousands_separator]
    }
    @options.merge!(options).reverse_merge!(Spree::Money.default_formatting_rules)
  end

end
