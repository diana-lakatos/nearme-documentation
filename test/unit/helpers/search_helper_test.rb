require 'test_helper'

class SearchHelperTest < ActionView::TestCase

  include MoneyRails::ActionViewExtension

  setup do
    @listing = FactoryGirl.create(:listing_with_10_dollars_per_hour)
    @location = @listing.location
  end

  test "#listing_price_information" do
    assert_equal listing_price_information(@listing), "$10 <span>/ hour</span>" 
    assert_equal listing_price_information(@listing, ['daily']), "$50 <span>/ day</span>" 
  end

  test "#location_price_information" do
    assert_equal location_price_information(@location), "From <span>$10</span> / hour" 
    assert_equal location_price_information(@location, ['daily']), "From <span>$50</span> / day" 
  end

end
