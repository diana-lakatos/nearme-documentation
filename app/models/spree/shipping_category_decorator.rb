Spree::ShippingCategory.class_eval do
  include Spree::Scoper
  belongs_to :country
end
