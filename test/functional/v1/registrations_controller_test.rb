require 'test_helper'

class V1::RegistrationsControllerTest < ActionController::TestCase

  setup do
    stub_request(:get, /.*api\.mixpanel\.com.*/)
    @tracker = Analytics::EventTracker.any_instance
  end

  test "successfull sign up and track" do
    @tracker.expects(:signed_up).with do |user, custom_options|
      user == assigns(:user) && custom_options == { signed_up_via: 'api', provider: 'native' }
    end
    assert_difference('User.count') do
      raw_post :create, {}, { name: 'maciek', email: 'email@example.com', password: 'maciekmaciek' }.to_json
    end
    assert :success
  end

end
