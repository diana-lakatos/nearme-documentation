require 'test_helper'

class V1::LocationsControllerTest < ActionController::TestCase

  ##
  # List

  test "list should return a list of location" do
    authenticate!
    company = FactoryGirl.create(:company, :name => 'company_XYZ', :creator_id => @user.id)
    @location = FactoryGirl.create(:location, :company_id => company.id)
    get :list
    assert_response :success
  end

  test "destroy should be successful" do
    authenticate!
    company = FactoryGirl.create(:company, :name => 'company_XYZ', :creator_id => @user.id)
    @location = FactoryGirl.create(:location, :company_id => company.id)
    delete :destroy, id: @location
    assert_response :success
  end

 end
