Spree::AppConfiguration.class_eval do
  preference :infinite_scroll, :boolean, default: false
  preference :random_products_for_cross_sell, :boolean, default: false
end
