require 'test_helper'

class Dashboard::Company::PaymentsControllerTest < ActionController::TestCase

  context 'create' do
    setup do
      @instance = PlatformContext.current.instance
      @user = FactoryGirl.create(:user)
      @company = FactoryGirl.create(:company, creator: @user)
      @product_type = FactoryGirl.create(:product_type)
      @shipping_category = FactoryGirl.create(:shipping_category)
      @shipping_category.company_id = @company.id
      @shipping_category.save!
      @shipping_method = FactoryGirl.create(:shipping_method, shipping_category_param: @shipping_category)
      @countries = Spree::Country.last(10)
      InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
      InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
      stub_billing_gateway(@instance)
      stub_active_merchant_interaction

      @order = FactoryGirl.create(:order_with_line_items, user: @user, state: 'complete', company: @company, payment_method: PaymentMethod.last )
      @billing_authorization = FactoryGirl.create(:billing_authorization, reference: @order)
      @order.finalize!

      sign_in @user
    end

    should 'create correct payment and update order' do
      assert_not @order.reload.paid?
      post :create, { orders_received_id: @order.number }
      assert @order.reload.paid?
    end
  end
end
