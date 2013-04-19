require 'test_helper'

class Locations::ReservationsControllerTest < ActionController::TestCase

  include Devise::TestHelpers

  context "making a booking" do

    setup do
      @listing = FactoryGirl.build(:listing_in_san_francisco)
      @user = FactoryGirl.build(:user)
      sign_in @user
      stub_request(:get, /.*api\.mixpanel\.com.*/)
    end

    should "track booking modal open" do
      Track::Book.expects(:opened_booking_modal)
      xhr :post, :review, { listings: booking_listing_params, location_id: @listing.location.id }
    end

  end

  def booking_listing_params
    {"0"=>{"id"=>"511", "bookings"=>{"0"=>{"date"=>"2013-04-19", "quantity"=>"1"}}}}
  end

end

