require 'test_helper'

class InstanceAdmin::Manage::AdminsControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
    FactoryGirl.create(:transactable_type_listing)
  end

  context 'index' do

    should 'find global instances and the ones that belong to current instance' do
      @role = FactoryGirl.create(:instance_admin_role)
      @role_that_belongs_to_other_instance = FactoryGirl.create(:instance_admin_role, :instance_id => FactoryGirl.create(:instance).id)
      @default_role = FactoryGirl.create(:instance_admin_role_default)
      @administrator_role = FactoryGirl.create(:instance_admin_role_administrator)
      get :index
      assert_equal [@administrator_role, @default_role, @role].sort, @controller.send(:instance_admin_roles).sort
    end

  end

  context 'create' do

    should 'be able to create user with only email and password' do
      assert_difference 'User.count' do
        post :create, :user => { :name => 'John Doe', :email => 'johndoe@example.com' }
      end
      assert assigns(:user).password.blank?
      assert_equal 'John Doe', assigns(:user).name
      assert_equal 'johndoe@example.com', assigns(:user).email
    end

    should 'not create an user without name or email' do
      assert_no_difference 'User.count' do
        post :create, :user => { :name => '', :email => 'johndoe@example.com' }
      end
      assert_no_difference 'User.count' do
        post :create, :user => { :name => 'John Doe', :email => '' }
      end
    end

    should 'create instance admin with default role' do
      assert_difference 'InstanceAdmin.count' do
        post :create, :user => { :name => 'John Doe', :email => 'johndoe@example.com' }
      end
      assert_equal 1, assigns(:user).instance_admins.count
    end

    should 'send an email with authentication token' do
      WorkflowStepJob.expects(:perform).with do |klass, user_id, creator_id|
        klass == WorkflowStep::SignUpWorkflow::CreatedByAdmin && assigns(:user).id == user_id && @user.id == creator_id
      end
      post :create, :user => { :name => 'John Doe', :email => 'johndoe@example.com' }
    end
  end

end
