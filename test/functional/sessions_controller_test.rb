require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  include Devise::TestHelpers

  should 'track log in' do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    @user = FactoryGirl.create(:user, email: 'user@example.com', password: 'secret', password_confirmation: 'secret')
    Track::User.expects(:logged_in)

    post :create, { user: { email: 'user@example.com', password: 'secret' } }
  end

end

