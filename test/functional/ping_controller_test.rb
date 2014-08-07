require 'test_helper'

class PingControllerTest < ActionController::TestCase
  should 'return 200' do
    get :index

    assert_response :success
  end
end
