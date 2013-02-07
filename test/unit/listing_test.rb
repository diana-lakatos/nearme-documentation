require 'test_helper'

class ListingTest < ActiveSupport::TestCase

  should belong_to(:location)
  should belong_to(:listing_type)
  should have_many(:reservations)
  should have_many(:ratings)
  should have_many(:unit_prices)

  should validate_presence_of(:location_id)
  should validate_presence_of(:name)
  should validate_presence_of(:description)
  should validate_presence_of(:quantity)
  should validate_presence_of(:listing_type_id)
  should validate_numericality_of(:quantity)
  should allow_value('x' * 250).for(:description)
  should_not allow_value('x' * 251).for(:description)

  setup do
    @listing = FactoryGirl.build(:listing)
  end

  test "setting the price with hyphens" do
    @listing.daily_price = "50-100"
    assert_equal 5000, @listing.price_cents
  end

  test "price with other strange characters" do
    @listing.daily_price = "50.0-!@\#$%^&*()100"
    assert_equal 5000, @listing.price_cents
  end

  test "negative price is 0" do
    @listing.daily_price = "-100"
    assert_equal 0, @listing.price_cents
  end
end
