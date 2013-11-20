require 'test_helper'

class InstanceAdmin::BaseControllerTest < ActionController::TestCase

  setup do
    sign_in FactoryGirl.create(:user)

  end

  context 'authorization' do

    context 'instance admin' do
      setup do
        InstanceAdmin::Authorizer.any_instance.stubs(:authorized?).returns(true)
      end

      should 'redirect user to root path if he is not instance administrator' do
        InstanceAdmin::Authorizer.any_instance.stubs(:instance_admin?).returns(false)
        get :index
        assert_redirected_to root_path
      end

    end

    context 'authorization' do

      setup do
        InstanceAdmin::Authorizer.any_instance.stubs(:instance_admin?).returns(true)
      end

      should 'end with success if user is authorized succesfully' do
        InstanceAdmin::Authorizer.any_instance.stubs(:authorized?).returns(true)
        get :index
        assert_redirected_to instance_admin_analytics_path
      end

      should 'redirect to root path is user is not authorized to view base controller' do
        InstanceAdmin::Authorizer.any_instance.stubs(:authorized?).with(InstanceAdmin::BaseController).returns(false)
        InstanceAdmin::Authorizer.any_instance.stubs(:authorized?).with(InstanceAdmin::AnalyticsController).returns(false)
        get :index
        assert_redirected_to root_path
      end
    end

  end

end
