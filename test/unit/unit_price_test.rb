require 'test_helper'

class UnitPriceTest < ActiveSupport::TestCase
  should belong_to(:listing)
  should validate_numericality_of(:price_cents)
end
