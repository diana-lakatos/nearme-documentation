require 'test_helper'

class PingTest < ActionDispatch::IntegrationTest
  should 'return 200' do
    get '/ping'

    assert_response :success
  end
end
