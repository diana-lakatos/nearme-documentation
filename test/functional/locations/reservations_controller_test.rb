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
      xhr :post, :review, { listings: booking_params_for(@listing), location_id: @listing.location.id }
    end

  end

  def booking_params_for(listing)
    {
      "0" => {
        "id" => listing.location.id,
        "bookings" => {
          "0" => {
            "date" => Chronic.parse('Monday'),
            "quantity"=>"1"
          }
        }
      }
    }
  end

end

