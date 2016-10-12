require 'test_helper'

class InstanceAdmin::Manage::ApprovalRequestsControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user, name: 'John Approval')
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
    sign_in @user

    @approval_request = FactoryGirl.build(:approval_request)
    @approval_request.owner = @user
    @approval_request.save!
  end

  context 'index' do
    should 'show a listing of approval requests' do
      get :index
      assert_select 'td', text: 'John Approval'
    end

    should 'not find approval request which does not exist' do
      get :index, q: 'Jane'
      assert_select 'td', count: 0
    end

    should 'find approval request by name' do
      get :index, q: 'John'
      assert_select 'td', count: 1, text: 'John Approval'
    end
  end
end
