require 'test_helper'

class InstanceAdmin::Manage::RatingSystemsControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
    sign_in @user
  end

  context 'index' do
    setup do
      get :index
    end

    should 'return status 200' do
      assert_equal 200, @response.status
    end

    should 'render index view' do
      assert_template :index
    end
  end

  context 'update_systems' do
    setup do
      Instance.any_instance.stubs(:rating_systems).returns([])
      post :update_systems
    end

    should 'redirect to index page' do
      assert_redirected_to instance_admin_manage_rating_systems_path
    end
  end
end