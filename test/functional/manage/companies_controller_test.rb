require 'test_helper'

class Manage::CompaniesControllerTest < ActionController::TestCase

  include Devise::TestHelpers

  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
  end

  test "should redirect to create company form if user does not have company" do
    get :index
    assert_redirected_to new_space_wizard_url
  end

end
