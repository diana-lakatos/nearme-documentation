require 'test_helper'
require 'mocha'

class V1::SocialProviderControllerTest < ActionController::TestCase

  setup do
    @user    = users(:one)
    @user.ensure_authentication_token!
    @request.env['Authorization'] = @user.authentication_token
  end

  test "should get facebook data" do
    Social::Facebook.stubs(:user_linked?).returns(false)

    get :show, provider: "facebook"
    assert_response :success

    json = JSON.parse response.body
    assert json
  end

  test "should update facebook data" do
    Social::Facebook.stubs(:user_linked?).returns(true)
    Social::Facebook.stubs(:get_user_info).returns(["123", {name:"John Smith"}])

    raw_put :update, {provider: "facebook"}, '{ "token": "abc123" }'
    assert_response :success

    json = JSON.parse response.body
    assert_equal true, json["facebook"]["linked"]
  end

  test "should delete facebook data" do
    Social::Facebook.stubs(:user_linked?).returns(false)

    delete :destroy, provider: "facebook"
    assert_response :success

    json = JSON.parse response.body
    assert_equal false, json["facebook"]["linked"]
  end

  test "should get twitter data" do
    Social::Twitter.stubs(:user_linked?).returns(false)

    get :show, provider: "twitter"
    assert_response :success

    json = JSON.parse response.body
    assert json
  end

  test "should update twitter data" do
    Social::Twitter.stubs(:user_linked?).returns(true)
    Social::Twitter.stubs(:get_user_info).returns(["123", {name:"John Smith"}])

    raw_put :update, {provider: "twitter"}, '{ "token": "abc123", "secret": "xyz789" }'
    assert_response :success

    json = JSON.parse response.body
    assert_equal true, json["twitter"]["linked"]
  end

  test "should delete twitter data" do
    Social::Twitter.stubs(:user_linked?).returns(false)

    delete :destroy, provider: "twitter"
    assert_response :success

    json = JSON.parse response.body
    assert_equal false, json["twitter"]["linked"]
  end

  test "should get linkedin data" do
    Social::Linkedin.stubs(:user_linked?).returns(false)

    get :show, provider: "linkedin"
    assert_response :success

    json = JSON.parse response.body
    assert json
  end

  test "should update linkedin data" do
    Social::Linkedin.stubs(:user_linked?).returns(true)
    Social::Linkedin.stubs(:get_user_info).returns(["123", {name:"John Smith"}])


    raw_put :update, {provider: "linkedin"}, '{ "token": "abc123", "secret": "xyz789" }'
    assert_response :success

    json = JSON.parse response.body
    assert_equal true, json["linkedin"]["linked"]
  end

  test "should delete linkedin data" do
    Social::Linkedin.stubs(:user_linked?).returns(false)

    delete :destroy, provider: "linkedin"
    assert_response :success

    json = JSON.parse response.body
    assert_equal false, json["linkedin"]["linked"]
  end

end
