require 'test_helper'

class V1::SocialControllerTest < ActionController::TestCase
  test 'should get data' do
    authenticate!
    User.any_instance.stubs(:linked_to?).with('facebook').returns(false)
    User.any_instance.stubs(:linked_to?).with('twitter').returns(true)
    User.any_instance.stubs(:linked_to?).with('linkedin').returns(false)

    get :show
    assert_response :success
  end
end
