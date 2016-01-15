require 'test_helper'

class InstanceAdmin::Manage::Admins::InstanceAdminsControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
    FactoryGirl.create(:instance)
  end

  context 'crud' do
    setup do
      InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
      InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
    end

    context 'create' do

      setup do
        @user_to_be_added = FactoryGirl.create(:user)
      end

      should 'be able to add user by email' do
        assert_difference "PlatformContext.current.instance.instance_admins.count" do
          post :create, { :email => @user_to_be_added.email }
        end
      end

      should 'not duplicate instance admin' do
        FactoryGirl.create(:instance_admin, :user_id => @user.id, :instance_id => PlatformContext.current.instance.id)
        assert_no_difference "PlatformContext.current.instance.instance_admins.count" do
          post :create, { :email => @user.email }
        end
      end

      should 'be able to add user to correct instance by email' do
        @second_instance = FactoryGirl.create(:instance, :name => "second instance")
        @third_instance = FactoryGirl.create(:instance, :name => "third instance")
        PlatformContext.any_instance.stubs(:instance).returns(@second_instance)
        @user_to_be_added = FactoryGirl.create(:user)
        @user = FactoryGirl.create(:user)
        sign_in @user
        assert_difference "Instance.find_by_name('second instance').instance_admins.size" do
          assert_no_difference "Instance.find_by_name('third instance').instance_admins.size" do
            post :create, { :email => @user_to_be_added.email }
          end
        end
      end

      should 'return error message if user has not been found' do
        email = "idontexist@example.com"
        assert_no_difference "PlatformContext.current.instance.instance_admins.size" do
          post :create, { :email => email }
        end
        assert_equal "Unfortunately we could not find a user with email \"#{email}\"", flash[:error]
      end


    end

    context 'update' do

      setup do
        @instance_admin = FactoryGirl.create(:instance_admin, :user_id => @user.id, :instance_id => PlatformContext.current.instance.id)
        @user_2 = FactoryGirl.create(:user)
        @instance_admin_2 = FactoryGirl.create(:instance_admin, :user_id => @user_2.id, :instance_id => PlatformContext.current.instance.id)
      end

      should 'update the role' do
        InstanceAdmin.any_instance.stubs(:instance_owner).returns(false)
        @role = FactoryGirl.create(:instance_admin_role)
        post :update, { :id => @instance_admin.id, :instance_admin_role_id => @role.id  }
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

      should 'allow to switch which admin is the owner' do
        assert @instance_admin.instance_owner
        assert !@instance_admin_2.instance_owner
        post :update, mark_as_owner: true, id: @instance_admin_2.id
        assert !@instance_admin.reload.instance_owner
        assert @instance_admin_2.reload.instance_owner
      end
    end

    context 'destroy' do

      setup do
        @instance_owner = FactoryGirl.create(:instance_admin, :user_id => FactoryGirl.create(:user).id, :instance_id => PlatformContext.current.instance.id)
        @instance_admin = FactoryGirl.create(:instance_admin, :user_id => FactoryGirl.create(:user).id, :instance_id => PlatformContext.current.instance.id)
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
