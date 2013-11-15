require 'test_helper'

class InstanceAdmin::Users::InstanceAdminRolesControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
    FactoryGirl.create(:instance) unless Instance.default_instance
    InstanceAdmin.create(:user_id => @user.id, :instance_id => Instance.default_instance.id)
  end

  context 'crud' do
    setup do
      InstanceAdmin::Authorizer.any_instance.stubs(:instance_admin?).returns(true)
      InstanceAdmin::Authorizer.any_instance.stubs(:authorized?).returns(true)
    end

    context 'create' do

      should 'be able to add new role correct permissions' do
        assert_difference "Instance.default_instance.instance_admin_roles.size" do
          post :create, :instance_admin_role => { :name => 'new role' }
        end
        assert_equal 'new role', assigns(:instance_admin_role).name
        assert assigns(:instance_admin_role).permission_analytics
        assert !assigns(:instance_admin_role).permission_users
      end

      should 'not duplicate role' do
        FactoryGirl.create(:instance_admin_role, :name => 'existing', :instance_id => Instance.default_instance.id)
        assert_no_difference "Instance.default_instance.instance_admin_roles.size" do
          post :create, :instance_admin_role => { :name => 'existing' }
        end
      end

    end

    context 'update' do

      setup do
        @role = FactoryGirl.create(:instance_admin_role)
      end

      should 'be able to update permission' do
        put :update, { :id => @role.id, :instance_admin_role => { :permission_settings => true }  }
        assert assigns(:instance_admin_role).permission_settings
      end

      should 'not be able to update instance_id' do
        put :update, { :id => @role.id, :instance_admin_role => { :instance_id => 999 } }
        assert_not_equal 999, assigns(:instance_admin_role).instance_id
      end

      should 'not be able to update global role' do
        @default_role = FactoryGirl.create(:instance_admin_role_default)
        assert_raises ActiveRecord::RecordNotFound do
          put :update, { :id => @default_role.id, :instance_admin_role => { :permission_settings => true } }
        end
        assert_nil assigns(:instance_admin_role)
      end

    end

    context 'destroy' do

      should 'allow to destroy custom role' do
        @role = FactoryGirl.create(:instance_admin_role)
        assert_difference('InstanceAdminRole.count', -1) do
          delete :destroy, :id => @role.id
        end
      end

      should 'not allow to destroy global role' do
        FactoryGirl.create(:instance_admin_role_default)
        assert_raises ActiveRecord::RecordNotFound do
          assert_no_difference 'InstanceAdminRole.count' do
            delete :destroy, :id => InstanceAdminRole.default_role.id
          end
        end
      end
      
    end
  end

end
