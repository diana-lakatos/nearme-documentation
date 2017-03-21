require 'test_helper'

class InstanceAdmin::Manage::PaymentsControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
    sign_in @user
  end

  context 'index' do
    should 'not show pending payments' do
      get :index

      payment_scope = assigns(:payments)
      assert payment_scope.object.to_sql.include?("NOT IN ('pending'))")
      assert_equal ["created_at DESC"], payment_scope.object.orders
      assert_equal Payment, payment_scope.object.model
      assert_equal PaymentGateway.all.sort_by(&:name), assigns(:payment_gateways)
      assert_response :success
    end
  end
end
