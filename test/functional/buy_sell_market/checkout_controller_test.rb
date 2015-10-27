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
        @order.company.company_address.update_column(:iso_country_code, 'PL')
        get :show, order_id: @order, id: 'address'
        assert_redirected_to cart_index_path
      end
    end

    context 'with billing gateway' do

      setup do
        FactoryGirl.create(:stripe_payment_gateway)
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

      context 'with two-step payout' do

        setup do
          stub_active_merchant_interaction
          @payment_gateway = FactoryGirl.create(:stripe_connect_payment_gateway)
          @payment_method = FactoryGirl.create(:credit_card_payment_method, payment_gateway: @payment_gateway)
          @payment_gateway.payment_currencies << (Currency.find_by_iso_code("PLN") || FactoryGirl.create(:currency_pl))
          @order = FactoryGirl.create(:order_waiting_for_payment, user: @user, service_fee_buyer_percent: 10, currency: 'PLN')
        end

        should 'correct proceed to complete state if all is ok' do
          @credit_card = stub('valid?' => true)
          ActiveMerchant::Billing::CreditCard.expects(:new).returns(@credit_card)
          assert_difference 'Spree::Payment.count' do
            put :update, order_id: @order, id: 'payment', order: { payment_method_id: @payment_method.id }
          end
          payment = @order.reload.payments.first
          assert_not_nil payment
          assert_equal 155, payment.amount.to_i
          assert_equal 'PLN', payment.currency
          assert_equal @order.company_id, payment.company_id
          assert_equal @order.instance_id, payment.instance_id
          assert_equal 'complete', @order.state
          assert_not_nil @order.billing_authorization
          assert @order.billing_authorization.success?
          assert_equal '54533', @order.billing_authorization.token
          assert_equal @payment_gateway.id, @order.billing_authorization.payment_gateway_id
        end

        should 'render error if CC is invalid' do
          ActiveMerchant::Billing::CreditCard.expects(:new).returns(stub('valid?' => false))
          assert_no_difference 'Spree::Payment.count' do
            put :update, order_id: @order, id: 'payment', order: { payment_method_id: @payment_method.id }
          end
          order = assigns(:order)
          assert_contains "Those credit card details don't look valid", order.errors[:cc].first
          assert_equal 'payment', order.state
          assert_nil order.billing_authorization
        end

        should 'render error if authorization failed' do
          ActiveMerchant::Billing::CreditCard.expects(:new).returns(stub('valid?' => true))
          authorize_response = OpenStruct.new(success?: false, message: 'No $$$ on account')
          PaymentAuthorizer.any_instance.stubs(:gateway_authorize).returns(authorize_response)

          assert_difference 'Spree::Payment.count' do
            put :update, order_id: @order, id: 'payment', order: { payment_method_id: @payment_method.id }
          end
          order = assigns(:order)
          assert_contains "No $$$ on account", order.errors[:cc]
          assert_equal 'payment', order.state
          assert_nil order.billing_authorization
          assert_equal 'failed', order.payments.first.state
          billing_authorization = order.billing_authorizations.first
          assert_not_nil billing_authorization
          refute billing_authorization.success?
          assert_equal authorize_response, billing_authorization.response
          assert_nil billing_authorization.token
          assert_equal @user.id, billing_authorization.user_id
        end
      end

      context 'with immediate payout' do

        setup do
          FactoryGirl.create(:additional_charge_type, currency: 'USD', amount: 15)
          @payment_gateway = FactoryGirl.create(:braintree_marketplace_payment_gateway)
          @payment_method = FactoryGirl.create(:credit_card_payment_method, payment_gateway: @payment_gateway)
          PlatformContext.current.instance.update_attributes(service_fee_host_percent: 15, service_fee_guest_percent: 10)
          @order = FactoryGirl.create(:order_waiting_for_payment, user: @user, currency: 'USD')
          ActiveMerchant::Billing::BraintreeMarketplacePayments.any_instance.stubs(:onboard!).returns(OpenStruct.new(success?: true))
          # create unrelated merchant account
          FactoryGirl.create(:braintree_marketplace_merchant_account, payment_gateway: @payment_gateway, merchantable: FactoryGirl.create(:company))
          # create related merchant account, the one who should receive $$$
          @merchant_account = FactoryGirl.create(:braintree_marketplace_merchant_account, payment_gateway: @payment_gateway, merchantable: @order.company)
          stubs = {
            authorize: OpenStruct.new(authorization: "54533", success?: true),
            capture: OpenStruct.new(success?: true),
            refund: OpenStruct.new(success?: true),
            void: OpenStruct.new(success?: true)
          }
          gateway = stub(capture: stubs[:capture], refund: stubs[:refund], void: stubs[:void])
          gateway.expects(:authorize).with do |total_amount_cents, credit_card_or_token, options|
            # 15 + 10 + 15 -> additional charge + guest fee + host fee
            total_amount_cents == 170.to_money(@order.currency).cents && options['service_fee_host'] == (5 + 15 + 7.5).to_money(@order.currency).cents
          end.returns(stubs[:authorize])
          PaymentGateway::BraintreeMarketplacePaymentGateway.any_instance.stubs(:gateway).returns(gateway).at_least(0)

        end

        should 'correct proceed to complete state if all is ok' do
          assert_difference 'Spree::Payment.count' do
            put :update, order_id: @order, id: 'payment', order: { payment_method_id: @payment_method.id, card_number: "4111 1111 1111 1111", card_exp_month: 1.year.from_now.month.to_s, card_exp_year: 1.year.from_now.year.to_s, card_code: '411', card_holder_first_name: 'Maciej', card_holder_last_name: 'Krajowski' }
          end
          payment = @order.reload.payments.first
          assert_equal 17000, @order.total_amount_to_charge.cents
          assert_equal 10000, @order.shipping_costs_cents
          assert_equal 5000, @order.subtotal_amount_to_charge.cents
          assert_equal 500 + 1500, @order.service_fee_amount_guest_cents
          assert_equal 750, @order.service_fee_amount_host_cents
          assert_not_nil payment
          assert_equal 170, payment.amount.to_i
          assert_equal 'USD', payment.currency
          assert_equal @order.company_id, payment.company_id
          assert_equal @order.instance_id, payment.instance_id
          assert_equal 'complete', @order.state
          assert_not_nil @order.billing_authorization
          assert @order.billing_authorization.success?
          assert_equal '54533', @order.billing_authorization.token
          assert_equal @merchant_account.id, @order.billing_authorization.merchant_account_id
          assert @order.billing_authorization.immediate_payout
          assert_equal @payment_gateway.id, @order.billing_authorization.payment_gateway_id
        end
      end
    end
  end

end
