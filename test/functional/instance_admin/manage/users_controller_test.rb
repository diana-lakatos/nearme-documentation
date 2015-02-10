require 'test_helper'

class InstanceAdmin::Manage::UsersControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user, :name => 'John X')
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
    sign_in @user
  end

  context 'index' do

    should 'show a listing of users associated with current instance' do
      @user_from_other_instance = FactoryGirl.create(:user)
      @user_from_other_instance.update_attribute(:instance_id, FactoryGirl.create(:instance).id)
      get :index
      assert_select 'td', "John X"
      assert_equal [@user], assigns(:users)
    end
  end

end
