require 'test_helper'

class InstanceAdmin::Analytics::ProfilesControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    2.times do
      create(:user, deleted_at: DateTime.now)
      create(:user, admin: true)
    end

    @admins = User.admin
    @deleted_users = User.only_deleted

    sign_in @user
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
  end

  context 'GET #show' do
    should 'list all users, including deleted and without admins' do
      get :show, format: :csv

      @deleted_users.each { |user| assert response.body.include?(user.email) }
      @admins.each        { |user| assert !response.body.include?(user.email) }

      assert response.body.include?(@user.email)
      assert_response :success
    end
  end
end
