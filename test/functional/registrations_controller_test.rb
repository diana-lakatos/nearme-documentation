require 'test_helper'

class RegistrationsControllerTest < ActionController::TestCase

  include Devise::TestHelpers

  should 'track sign up' do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    #Track::User.expects(:signed_up)

    assert_difference('User.count') do
      post :create, user: { name: 'Test User', email: 'user@example.com', password: 'secret' }
    end
  end

end

