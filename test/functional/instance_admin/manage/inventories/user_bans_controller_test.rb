require 'test_helper'

class InstanceAdmin::Manage::Inventories::UserBansControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    @instance = FactoryGirl.create(:instance)
    PlatformContext.any_instance.stubs(:instance).returns(@instance)
    @transactable_type = FactoryGirl.create(:transactable_type)
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
    sign_in @user
    @user_to_be_banned = FactoryGirl.create(:user)
  end

  context 'create' do

    should 'ban user' do
      assert_difference 'UserBan.count', 1 do
        post :create, { inventory_id: @user_to_be_banned.id }
      end
      @user_ban = assigns(:user_ban)
      assert_equal @user_to_be_banned.id, @user_ban.user_id
      assert_equal @user.id, @user_ban.creator_id
      assert_equal @instance.id, @user_ban.instance_id
    end
  end

end
