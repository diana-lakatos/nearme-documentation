require 'test_helper'

class V1::ReservationsControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    @user.ensure_authentication_token!
    @request.env['Authorization'] = @user.authentication_token
  end

  test "index should get resevations" do
    get :index
    assert_response :success
  end

  test "past should get resevations" do
    get :past
    assert_response :success
  end

  test "future should get resevations" do
    get :future
    assert_response :success
  end

end
