require 'test_helper'

class InstanceAdmin::Manage::Users::UserBansControllerTest < ActionController::TestCase
  setup do
    @instance = FactoryGirl.create(:instance)
    PlatformContext.any_instance.stubs(:instance).returns(@instance)
    @user = FactoryGirl.create(:user)
    @transactable_type = FactoryGirl.create(:transactable_type)
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
    sign_in @user
    @user_to_be_banned = FactoryGirl.create(:user)
    @existing_user_ban = FactoryGirl.create(:user_ban)
  end

  context 'create' do
    should 'ban user' do
      assert_difference 'UserBan.count', 1 do
        post :create, user_id: @user_to_be_banned.id
      end
      @user_ban = assigns(:user_ban)
      assert_equal @user_to_be_banned.id, @user_ban.user_id
      assert_equal @user.id, @user_ban.creator_id
      assert_equal @instance.id, @user_ban.instance_id
      assert_equal @user_ban.created_at.to_i, @user_to_be_banned.reload.banned_at.to_i
      assert_nil @user.reload.banned_at
    end
  end

  context 'delete' do
    should 'unban user' do
      assert_no_difference 'UserBan.count' do
        delete :destroy, id: @existing_user_ban.id, user_id: @existing_user_ban.user.id
      end
      assert_nil @existing_user_ban.user.reload.banned_at
    end
  end
end
