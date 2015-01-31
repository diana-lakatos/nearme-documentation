Spree::ShippingRate.class_eval do
  include Spree::Scoper

  scope :only_selected, where(selected: true)
end
