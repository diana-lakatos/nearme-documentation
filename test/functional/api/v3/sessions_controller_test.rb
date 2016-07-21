require 'test_helper'

class Api::V3::SessionsControllerTest < ActionController::TestCase

  PASSWORD = 'password123'

  setup do
    @user = FactoryGirl.create(:user, password: PASSWORD, password_confirmation: PASSWORD)
  end

  test "should authenticate valid credentials" do
    post :create, { email: @user.email, password: PASSWORD, format: :json }
    assert_response :success
    assert_equal ApiSerializer.serialize_object(OpenStruct.new(id: @user.id, token: @user.reload.authentication_token, jsonapi_serializer_class_name: 'SessionJsonSerializer' )), JSON.parse(@response.body)
  end

  test "search should raise when given invalid credentials" do
    post :create, { email: @user.email, password: 'invalid', format: :json }
    assert_response :unauthorized
    assert @response.body.include?('Invalid email or password'), "Have not found 'invalid' in #{@response.body}"
  end

end

