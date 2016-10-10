require 'test_helper'

class Dashboard::Company::PaymentsControllerTest < ActionController::TestCase
  context 'create' do
    setup do
      @instance = PlatformContext.current.instance
      @user = FactoryGirl.create(:user)
      @company = FactoryGirl.create(:company, creator: @user)
      InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
      InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
      stub_billing_gateway(@instance)
      stub_active_merchant_interaction

      @order = FactoryGirl.create(:purchase_with_payment, user: @user, company: @company)

      sign_in @user
    end

    should 'create correct payment and update order' do
      get :show, orders_received_id: @order.id, id: @order.payment.id
      assert_response :success
    end
  end
end
