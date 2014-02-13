require 'test_helper'

class InstanceAdmin::Manage::InventoriesControllerTest < ActionController::TestCase

  setup do
    @instance = FactoryGirl.create(:instance)
    @user = FactoryGirl.create(:user, :instance => @instance, :name => 'John X')
    @other_instance = FactoryGirl.create(:instance)
    PlatformContext.any_instance.stubs(:instance).returns(@instance)
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
    sign_in @user
  end

  context 'index' do

    should 'show a listing of users associated with current instance' do
      @user_from_other_instance = FactoryGirl.create(:user, :instance => @other_instance)
      get :index
      assert_select 'td', "John X"
      assert_equal [@user], assigns(:users)
    end
  end

end
