require 'test_helper'

class V1::SocialControllerTest < ActionController::TestCase

  test "should get data" do
    pending "until Sai reviews"
    Social::Facebook.stubs(:user_linked?).returns(false)
    Social::Twitter.stubs(:user_linked?).returns(true)
    Social::Linkedin.stubs(:user_linked?).returns(false)

    get :show
    assert_response :success
  end

end
