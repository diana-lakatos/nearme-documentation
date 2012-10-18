require 'test_helper'

class UnitPriceTest < ActiveSupport::TestCase
  should belong_to(:listing)
  should validate_numericality_of(:price_cents)
  test "it delegates to the listings currency" do
    listing = FactoryGirl.create(:listing)
    listing.stubs(:currency).returns(Money::Currency.find('EUR'))
    up = UnitPrice.new(price_cents: 2000, listing: listing)
    assert up.currency == Money::Currency.find('EUR')
  end
end
