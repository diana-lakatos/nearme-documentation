require 'test_helper'

class V1::LocationsControllerTest < ActionController::TestCase

  setup do
    authenticate!
    company = FactoryGirl.create(:company, :name => 'company_XYZ', :creator_id => @user.id)
    @location = FactoryGirl.create(:location, :company_id => company.id)
  end

  ##
  # List

  test "list should return a list of location" do
    get :list
    assert_response :success
  end

  ##
  # C*UD
  #
  test "create should be successful" do
    post  :create, {location: {name: 'My location', address: 'My address', description: 'nice location', location_type_id: 1, email: 'test@desksnear.me', latitude:10, longitude:10}}

    assert_response :success

  end

  test "update should be successful" do
    new_name = 'My location'
    put :update, id: @location, location: { name: new_name }, format: 'json'
    @location = Location.find(@location.id)
    assert_equal new_name, @location.name
    assert_response :success

  end

  test "destroy should be successful" do
    delete :destroy, id: @location
    assert_response :success
  end

 end
