require 'test_helper'

class InstanceAdmin::Users::InstanceAdminsControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
    FactoryGirl.create(:instance)
  end

  context 'authorization' do

    should 'get correct permitting name' do
      InstanceAdmin::Authorizer.any_instance.stubs(:instance_admin?).returns(true)
      InstanceAdmin::Authorizer.any_instance.expects(:authorized?).with do |controller|
        controller == InstanceAdmin::UsersController
      end.returns(true)
      post :create
    end

  end

  context 'crud' do
    setup do
      InstanceAdmin::Authorizer.any_instance.stubs(:instance_admin?).returns(true)
      InstanceAdmin::Authorizer.any_instance.stubs(:authorized?).returns(true)
    end

    context 'create' do

      setup do
        @user_to_be_added = FactoryGirl.create(:user)
      end

      should 'be able to add user by email' do
        assert_difference "Instance.default_instance.instance_admins.size" do
          post :create, { :email => @user_to_be_added.email }
        end
      end

      should 'not duplicate instance admin' do
        FactoryGirl.create(:instance_admin, :user_id => @user.id, :instance_id => Instance.default_instance.id)
        assert_no_difference "Instance.default_instance.instance_admins.size" do
          post :create, { :email => @user.email }
        end
      end

      should 'be able to add user to correct instance by email' do
        @second_instance = FactoryGirl.create(:instance, :name => "second instance")
        @third_instance = FactoryGirl.create(:instance, :name => "third instance")
        PlatformContext.any_instance.stubs(:instance).returns(@second_instance)
        assert_difference "Instance.find_by_name('second instance').instance_admins.size" do
          assert_no_difference "Instance.find_by_name('third instance').instance_admins.size" do
            post :create, { :email => @user_to_be_added.email }
          end
        end
      end

      should 'return error message if user has not been found' do
        email = "idontexist@example.com"
        assert_no_difference "Instance.default_instance.instance_admins.size" do
          post :create, { :email => email }
        end
        assert_equal flash[:error], "Unfortunately we could not find user with email \"#{email}\""
      end


    end

    context 'update' do

      setup do
        @instance_admin = FactoryGirl.create(:instance_admin, :user_id => @user.id, :instance_id => Instance.default_instance.id)
      end

      should 'update the role' do
        InstanceAdmin.any_instance.stubs(:instance_owner).returns(false)
        @role = FactoryGirl.create(:instance_admin_role)
        put :update, { :id => @instance_admin.id, :instance_admin_role_id => @role.id  }
        assert_equal @role.id, assigns(:instance_admin).instance_admin_role_id 
      end

      should 'know which role does not belong to the instance' do
        InstanceAdmin.any_instance.stubs(:instance_owner).returns(false)
        @role = FactoryGirl.create(:instance_admin_role)
        @role_that_belongs_to_other_instance = FactoryGirl.create(:instance_admin_role, :instance_id => FactoryGirl.create(:instance, :name => 'other instance').id)
        assert_raises ActiveRecord::RecordNotFound do
          put :update, { :id => @instance_admin.id, :instance_admin_role_id => @role_that_belongs_to_other_instance.id }
        end
      end

      should 'be able to find global role' do
        InstanceAdmin.any_instance.stubs(:instance_owner).returns(false)
        put :update, { :id => @instance_admin.id, :instance_admin_role_id => InstanceAdminRole.default_role.id }
        assert_equal InstanceAdminRole.default_role.id, assigns(:instance_admin).instance_admin_role_id 
      end

      should 'not allow to degradade instance owner' do
        InstanceAdmin.any_instance.stubs(:instance_owner).returns(true)
        role_id = InstanceAdminRole.administrator_role.id
        @instance_admin.update_attribute(:instance_admin_role_id, role_id)
        put :update, { :id => @instance_admin.id, :instance_admin_role_id => InstanceAdminRole.default_role.id }
        assert_equal role_id, assigns(:instance_admin).instance_admin_role_id 
      end
    end

    context 'destroy' do

      setup do
        @instance_owner = FactoryGirl.create(:instance_admin, :user_id => FactoryGirl.create(:user).id, :instance_id => Instance.default_instance.id)
        @instance_admin = FactoryGirl.create(:instance_admin, :user_id => FactoryGirl.create(:user).id, :instance_id => Instance.default_instance.id)
      end

      should 'allow to destroy regular instance admin' do
        assert_difference('InstanceAdmin.count', -1) do
          delete :destroy, :id => @instance_admin
        end
      end

      should 'not allow to destroy instance owner' do
        assert_no_difference 'InstanceAdmin.count' do
          delete :destroy, :id => @instance_owner
        end
      end
      
    end
  end

end
