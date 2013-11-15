require 'test_helper'

class InstanceAdmin::SettingsControllerTest < ActionController::TestCase

  context 'authorization' do

    setup do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end

    should 'end with success if user is authorized to view settings' do
      InstanceAdmin::Authorizer.any_instance.stubs(:instance_admin?).returns(true)
      InstanceAdmin::Authorizer.any_instance.stubs(:authorized?).at_least_once.returns(false)
      InstanceAdmin::Authorizer.any_instance.stubs(:authorized?).with(InstanceAdmin::SettingsController).returns(true)
      get :index
      assert_response :success
    end

    should 'redirect user to instance admin path if he is authorized for analytics' do
      InstanceAdmin::Authorizer.any_instance.stubs(:instance_admin?).returns(true)
      InstanceAdmin::Authorizer.any_instance.stubs(:authorized?).with(InstanceAdmin::AnalyticsController).returns(true)
      InstanceAdmin::Authorizer.any_instance.stubs(:authorized?).with(InstanceAdmin::SettingsController).returns(false)
      get :index
      assert_redirected_to instance_admin_path
    end

    should 'not end up in infinite loop if user has no access to analytics' do
      InstanceAdmin::Authorizer.any_instance.stubs(:instance_admin?).returns(true)
      InstanceAdmin::Authorizer.any_instance.stubs(:authorized?).with(InstanceAdmin::AnalyticsController).returns(false)
      InstanceAdmin::Authorizer.any_instance.stubs(:authorized?).with(InstanceAdmin::SettingsController).returns(false)
      get :index
      assert_redirected_to root_path
    end


  end

end
