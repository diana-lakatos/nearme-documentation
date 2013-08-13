require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    @request.env["devise.mapping"] = Devise.mappings[:user]
    stub_request(:get, /.*api\.mixpanel\.com.*/)
    @tracker = Analytics::EventTracker.any_instance
  end

  should 'successfully sign up and track' do
    @tracker.expects(:logged_in).with do |user, custom_options|
      user == @user && custom_options == { provider: 'native' }
    end
    post :create, user: { email: @user.email, password: @user.password }
  end

end

