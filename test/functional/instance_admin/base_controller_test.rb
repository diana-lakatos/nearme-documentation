# frozen_string_literal: true
# require 'test_helper'

class InstanceAdmin::BaseControllerTest < ActionController::TestCase
  setup do
    sign_in FactoryGirl.create(:user)
  end

  context 'authorization' do
    context 'instance admin' do
      setup do
        InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
      end

      should 'redirect user to root path if he is not instance administrator' do
        InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(false)
        get :index
        assert_redirected_to root_path
      end
    end

    context 'authorization' do
      setup do
        InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
      end

      should 'end with success if user is authorized succesfully' do
        InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
        get :index
        assert_redirected_to instance_admin_analytics_path
      end

      should 'redirect to root path is user is not authorized to view base controller' do
        InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(false)
        InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(false)
        get :index
        assert_redirected_to root_path
      end
    end
  end
end
