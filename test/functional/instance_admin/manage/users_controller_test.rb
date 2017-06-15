require 'test_helper'

class InstanceAdmin::Manage::UsersControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user, name: 'John X')
    @deleted_user = FactoryGirl.create(:user, name: 'Deleted Jane', email: 'jane@example.com').destroy
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
    sign_in @user
  end

  context 'index' do
    should 'show a listing of users associated with current instance without deleted' do
      @user_from_other_instance = FactoryGirl.create(:user)
      @user_from_other_instance.update_attribute(:instance_id, FactoryGirl.create(:instance).id)
      get :index
      assert_select 'td', 'John X'      
      assert_equal [@user.id].sort, assigns(:users).map(&:id).sort
    end

    should 'show a listing of users associated with current instance with deleted' do
      @user_from_other_instance = FactoryGirl.create(:user)
      @user_from_other_instance.update_attribute(:instance_id, FactoryGirl.create(:instance).id)
      get :index, state: 'deleted'
      assert_select 'td', 'Deleted Jane'
      assert_equal [@deleted_user.id].sort, assigns(:users).map(&:id).sort
    end

    should 'delete a user' do
      post :destroy, id: @user.id
      assert_redirected_to edit_instance_admin_manage_user_path(@user)
      assert_equal @user, assigns(:user)
      assert_not_nil @user.reload.deleted_at
    end

    should 'restore a deleted user' do
      post :restore, id: @deleted_user.id
      assert_redirected_to edit_instance_admin_manage_user_path(@deleted_user)
      assert_equal @deleted_user, assigns(:user)
      assert_nil @user.reload.deleted_at
    end

    should 'warn if a user cannot be restored' do
      @duplicate_user = FactoryGirl.create(:user, name: 'Dup Deleted Jane', email: 'jane@example.com')
      post :restore, id: @deleted_user.id
      assert_redirected_to edit_instance_admin_manage_user_path(@deleted_user)
      assert_equal @deleted_user, assigns(:user)
      assert_equal 'User could not be restored, that email address is currently in use.', flash[:error]
      assert_not_nil @deleted_user.reload.deleted_at
    end
  end
end
