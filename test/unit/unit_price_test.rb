require 'test_helper'

class UnitPriceTest < ActiveSupport::TestCase
  should belong_to(:listing)
  should validate_numericality_of(:price_cents)
  should validate_uniqueness_of(:period).scoped_to([:price_cents, :listing_id])



  test "it delegates to the listings currency" do
    listing = FactoryGirl.build(:listing)
    listing.stubs(:currency).returns(Money::Currency.find('EUR'))
    up = UnitPrice.new(price_cents: 2000, listing: listing)
    assert_equal Money::Currency.find('EUR'), up.currency
  end
end
