require 'test_helper'

class V1::AuthenticationsControllerTest < ActionController::TestCase

  PASSWORD = "password123"

  setup do
    @user = FactoryGirl.build(:user)
    @user.password = @user.password_confirmation = PASSWORD
    @user.save!
  end

  ##
  # Email/Password Authentication

  test "should authenticate valid credentials" do
    raw_post :create, {}, auth_hash.to_json
    assert_response :success

    @user.reload
    @json = JSON.parse(@response.body)
    assert_equal @user.authentication_token, @json["token"]
  end

  test "search should raise when given invalid credentials" do
    assert_raise DNM::Unauthorized do
      raw_post :create, {}, auth_hash.merge(password: "nope").to_json
    end
  end

  ##
  # Social Authentication

  test "social should authenticate valid social credentials" do
    @user.authentications.find_or_create_by_provider("facebook").tap do |a|
      a.uid = "123456"
    end.save!

    Social::Facebook.stubs(:get_user_info).returns(["123456", {"name" => @user.name}])

    raw_post :social, {provider: "facebook"}, '{ "token": "abc123" }'
    assert_response :success

    @user.reload
    @json = JSON.parse(@response.body)
    assert_equal @user.authentication_token, @json["token"]
  end

  test "social should raise when given invalid social credentials" do
    assert_raise DNM::MissingJSONData do
      raw_post :social, {provider: "facebook"}, '{ "notatoken": "nope" }'
    end
  end

  test "social should raise when valid social credentials aren't previously saved" do
    Social::Facebook.stubs(:get_user_info).returns(["123456", {"name" => @user.name}])

    assert_raise DNM::Unauthorized do
      raw_post :social, {provider: "facebook"}, '{ "token": "abc123" }'
    end
  end

  test "social should raise when valid social credentials aren't previously saved but a user with that email exists" do
    @user.save # Make sure the user can be found in the db

    Social::Facebook.stubs(:get_user_info).returns(["123456", {"name" => @user.name, "email" => @user.email}])

    assert_raise DNM::UnauthorizedButUserExists do
      raw_post :social, {provider: "facebook"}, '{ "token": "abc123" }'
    end
  end


  private

  def auth_hash
    { email: @user.email, password: PASSWORD }
  end
end
