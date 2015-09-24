Spree::AppConfiguration.class_eval do
  preference :infinite_scroll, :boolean, default: false
  preference :random_products_for_cross_sell, :boolean, default: false
  preference :products_table, :boolean, default: false
  preference :currency_symbol_position, :string, default: 'before'
  preference :currency_decimal_mark, :string, default: "."
  preference :currency_thousands_separator, :string, default: ","
end
