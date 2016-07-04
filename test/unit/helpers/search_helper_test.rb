require 'test_helper'

class SearchHelperTest < ActionView::TestCase

  include MoneyRails::ActionViewExtension

  context 'listing' do
    setup do
      @listing = FactoryGirl.create(:listing_with_10_dollars_per_hour)
      @location = @listing.location
    end

    should "#listing_price_information" do
      assert_equal "$12", @listing.decorate.price_with_currency(Money.new(1200, 'EUR'))
      assert_equal "$10 <span>/ hour</span>", @listing.decorate.lowest_price_with_currency
    end
  end

end
