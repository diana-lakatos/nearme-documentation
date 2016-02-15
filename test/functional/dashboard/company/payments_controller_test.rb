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

      @order = FactoryGirl.create(:order_with_line_items, user: @user, state: 'complete', company: @company )
      @order.build_payment(payment_method: FactoryGirl.create(:credit_card_payment_method), credit_card_form: FactoryGirl.attributes_for(:credit_card_form))
      @order.payment.authorize
      @order.finalize!

      sign_in @user
    end

    should 'create correct payment and update order' do
      assert_not @order.reload.paid?
      request.env["HTTP_REFERER"] = dashboard_company_orders_received_path(@order)
      post :capture, { orders_received_id: @order.number, id: @order.payment }
      assert_redirected_to dashboard_company_orders_received_path(@order)
      assert @order.payment.reload.paid?
      assert @order.reload.paid?
    end
  end
end
