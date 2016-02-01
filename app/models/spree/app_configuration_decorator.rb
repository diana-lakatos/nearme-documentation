Spree::AppConfiguration.class_eval do
  preference :currency_symbol_position, :string, default: 'before'
  preference :currency_decimal_mark, :string, default: "."
  preference :currency_thousands_separator, :string, default: ","
end
