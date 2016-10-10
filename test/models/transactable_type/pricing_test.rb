require 'test_helper'

class TransactableType::PricingTest < ActiveSupport::TestCase
  should belong_to :action
  should validate_numericality_of(:min_price_cents)
  should validate_numericality_of(:max_price_cents)
  should_not allow_value(-30).for(:max_price_cents)
  should_not allow_value(-30).for(:min_price_cents)
  should_not allow_value(-30).for(:min_price_cents)
  should_not allow_value(TransactableType::Pricing::MAX_PRICE + 1).for(:min_price_cents)
  should_not allow_value(TransactableType::Pricing::MAX_PRICE + 1).for(:max_price_cents)
end
