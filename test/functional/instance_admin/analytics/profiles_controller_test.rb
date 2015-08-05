require 'test_helper'

class InstanceAdmin::Analytics::ProfilesControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    2.times { create(:user, deleted_at: DateTime.now) }
    @with_deleted = User.with_deleted
    @ids = []
    2.times { @ids << create(:user, admin: false) }
    @without = User.without(@ids)

    sign_in @user
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
  end

  context 'GET #show' do
    should 'list all users, including deleted and without admins' do
      User.expects(:without).once.returns(@without)
      User.expects(:with_deleted).once.returns(@with_deleted)
      get :show, format: :csv
      assert_response :success
    end
  end

end
