require 'test_helper'

class BuySellMarket::CheckoutControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    stub_mixpanel
    sign_in @user
  end

  context 'show' do

    context 'without billing gateway' do

      setup do
        @order = FactoryGirl.create(:order_with_line_items, user: @user)
      end

      should 'should display correct error message' do
        get :show, order_id: @order, id: 'address'
        assert_contains 'The seller does not support payments for the selected country.', flash[:error]
      end


      should 'redirect if no payment gateway available at all' do
        get :show, order_id: @order, id: 'address'
        assert_redirected_to cart_index_path
      end

      should 'redirect if no payment gateway available for given country' do
        FactoryGirl.create(:stripe_payment_gateway)
        FactoryGirl.create(:country_payment_gateway)
        @order.company.company_address.update_column(:iso_country_code, 'PL')
        get :show, order_id: @order, id: 'address'
        assert_redirected_to cart_index_path
      end
    end

    context 'with billing gateway' do

      setup do
        FactoryGirl.create(:country_payment_gateway, payment_gateway_id: FactoryGirl.create(:stripe_payment_gateway).id)
      end

      context 'address' do
        setup do
          @order = FactoryGirl.create(:order_with_line_items, user: @user)
        end

        should 'render show action correctly' do
          get :show, order_id: @order, id: 'address'
          assert_response :success
        end
      end

    end

  end

  context 'update' do

      context 'payment' do

        setup do
          @payment_gateway = FactoryGirl.create(:country_payment_gateway, payment_gateway_id: FactoryGirl.create(:stripe_payment_gateway).id).payment_gateway
          @order = FactoryGirl.create(:order_waiting_for_payment, user: @user, service_fee_buyer_percent: 10, currency: 'PLN')
        end

        should 'correct proceed to complete state if all is ok' do
          @credit_card = stub('valid?' => true)
          @authorize_response = { token: 'abc' }
          ActiveMerchant::Billing::CreditCard.expects(:new).returns(@credit_card)
          PaymentGateway.any_instance.expects(:authorize).with do |amount, currency, credit_card|
            amount == Money.new(155_00, 'PLN')  && credit_card == @credit_card && currency == 'PLN'
          end.returns(@authorize_response)
          assert_difference 'Spree::Payment.count' do
            put :update, order_id: @order, id: 'payment'
          end
          payment = @order.reload.payments.first
          assert_not_nil payment
          assert_equal 155, payment.amount.to_i
          assert_equal 'PLN', payment.currency
          assert_equal @order.company_id, payment.company_id
          assert_equal @order.instance_id, payment.instance_id
          assert_equal 'pending', payment.state
          assert_equal 'complete', @order.state
          assert_not_nil @order.billing_authorization
          assert @order.billing_authorization.success?
          assert_equal 'abc', @order.billing_authorization.token
          assert_equal @payment_gateway.id, @order.billing_authorization.payment_gateway_id
        end

        should 'render error if CC is invalid' do
          ActiveMerchant::Billing::CreditCard.expects(:new).returns(stub('valid?' => false))
          assert_no_difference 'Spree::Payment.count' do
            put :update, order_id: @order, id: 'payment'
          end
          order = assigns(:order)
          assert_contains "Those credit card details don't look valid", order.errors[:cc].first
          assert_equal 'payment', order.state
          assert_nil order.billing_authorization
        end

        should 'render error if authorization failed' do
          authorize_response = { error: 'No $$$ on account' }
          ActiveMerchant::Billing::CreditCard.expects(:new).returns(stub('valid?' => true))
          PaymentGateway.any_instance.expects(:authorize).returns(authorize_response)
          assert_difference 'Spree::Payment.count' do
            put :update, order_id: @order, id: 'payment'
          end
          order = assigns(:order)
          assert_contains "No $$$ on account", order.errors[:cc].first
          assert_equal 'payment', order.state
          assert_nil order.billing_authorization
          assert_equal 'failed', order.payments.first.state
          billing_authorization = order.billing_authorizations.first
          assert_not_nil billing_authorization
          refute billing_authorization.success?
          assert_equal authorize_response.stringify_keys, billing_authorization.response
          assert_nil billing_authorization.token
          assert_equal @user.id, billing_authorization.user_id
        end
      end
  end

end
