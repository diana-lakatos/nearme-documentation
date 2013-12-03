require 'test_helper'

class InstanceAdmin::SettingsControllerTest < ActionController::TestCase

  context 'authorization' do

    setup do
      @user = FactoryGirl.create(:user)
      sign_in @user
      InstanceAdmin::Authorizer.any_instance.stubs(:instance_admin?).returns(true)
    end

    should 'end with success if user is authorized to view settings' do
      InstanceAdmin::Authorizer.any_instance.stubs(:authorized?).at_least_once.returns(false)
      InstanceAdmin::Authorizer.any_instance.stubs(:authorized?).with(InstanceAdmin::SettingsController).returns(true)
      get :show
      assert_response :success
      assert_template :show
    end

    should 'redirect user to instance admin path if he is authorized for analytics' do
      InstanceAdmin::Authorizer.any_instance.stubs(:authorized?).with(InstanceAdmin::AnalyticsController).returns(true)
      InstanceAdmin::Authorizer.any_instance.stubs(:authorized?).with(InstanceAdmin::SettingsController).returns(false)
      get :show
      assert_redirected_to instance_admin_analytics_path
    end

    should 'not end up in infinite loop if user has no access to analytics' do
      InstanceAdmin::Authorizer.any_instance.stubs(:authorized?).returns(false)
      get :show
      assert_redirected_to root_path
    end


  end

end
