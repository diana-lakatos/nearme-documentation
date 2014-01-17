require 'test_helper'

class Locations::ListingsControllerTest < ActionController::TestCase

  setup do
    @listing = FactoryGirl.create(:listing)
    @location = @listing.location
    stub_mixpanel
  end

  should "redirect to locations#show and remember which listing has been chosen" do
    get :show, location_id: @location.id, id: @listing
    assert_response :redirect
    assert_redirected_to location_path(@location, @listing)
  end

end

