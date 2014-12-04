class Spree::ShippingRateDecorator < Draper::Decorator
  include Draper::LazyHelpers
  include MoneyRails::ActionViewExtension

  delegate_all

  def name
    "#{object.name} - #{object.display_cost}"
  end
end
