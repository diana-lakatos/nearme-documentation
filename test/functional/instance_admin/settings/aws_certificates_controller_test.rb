require 'test_helper'

class InstanceAdmin::Settings::AwsCertificatesControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
  end

  test "#get certificates index" do

    get :index
    assert_response :success
  end

  test "#get certificates new" do

    get :new
    assert_response :success
  end
end
