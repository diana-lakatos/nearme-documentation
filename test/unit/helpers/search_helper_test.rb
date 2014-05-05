require 'test_helper'

class SearchHelperTest < ActionView::TestCase

  include MoneyRails::ActionViewExtension

  setup do
    @listing = FactoryGirl.create(:listing_with_10_dollars_per_hour)
    @location = @listing.location
  end

  test "#listing_price_information" do
    assert_equal "$10 <span>/ hour</span>", listing_price_information(@listing)
    assert_equal "$50 <span>/ day</span>", listing_price_information(@listing, ['daily'])
  end

  test "#location_price_information" do
    assert_equal "From <span>$10</span> / hour", location_price_information(@location)
    assert_equal "From <span>$50</span> / day", location_price_information(@location, ['daily'])
  end

end
