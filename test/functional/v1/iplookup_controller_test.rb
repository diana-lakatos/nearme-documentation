require 'test_helper'

class V1::IplookupControllerTest < ActionController::TestCase

  # TODO: Mock out Geocoder calls!

  test "should get data" do
    get :index
    assert_response :success
  end

  test "data should be JSON" do
    get :index

    json = JSON.parse(response.body)
    assert json
    assert json["ip"]
    assert json["boundingbox"]
    assert json["location"]
  end

end
