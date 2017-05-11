# frozen_string_literal: true
require 'test_helper'

module Api
  module V4
    module User
      class CheckoutsControllerTest < ActionController::TestCase
        setup do
          @custom_attachment = FactoryGirl.create(:custom_attachment)
        end

        context 'with reservation' do
          setup do
            @reservation = FactoryGirl.create(:reservation_without_payment)
            @user = @reservation.user
            @shopping_cart = @user.current_shopping_cart.tap { |s| s.orders << @reservation; s.save! }
            @payment_gateway = stub_billing_gateway(@reservation.instance)
            stub_request(:post, 'https://sk_test_DoIom7ZOL848ziY39cC75lI0:@api.stripe.com/v1/customers')
              .with(body: { 'card' => 'abc123', 'email' => @user.email })
              .to_return(status: 200, body: stripe_customer_json, headers: {})

            stub_request(:post, 'https://sk_test_DoIom7ZOL848ziY39cC75lI0:@api.stripe.com/v1/charges')
              .with(body: {
                      'amount' => '5500', 'capture' => 'false',
                      'card' => 'card_1AIGn22eZvKYlo2CW5ie93yI',
                      'currency' => 'usd', 'customer' => 'cus_AdXsZs1LwO6UjG',
                      'payment_user_agent' => 'Stripe/v1 ActiveMerchantBindings/1.47.0'
                    })
              .to_return(status: 200, body: stripe_charge_json, headers: {})
            @payment_method = @payment_gateway.payment_methods.credit_card.first
            sign_in @user
          end

          should 'complete checkout' do
            post :create, { form_configuration_id: form_configuration.id, form: { payment: { credit_card_token: 'abc123' } } }
            assert @shopping_cart.reload.checkout_at
            order = @shopping_cart.orders.first
            assert order.payment.present?
            assert_equal 5500, order.payment.total_amount_cents
            assert_equal 'USD', order.payment.currency
            assert order.payment.authorized?
            assert order.unconfirmed?
            assert_equal @reservation.transactable.company_id, order.payment.company_id
            refute order.payment.paid?
            assert_equal 500, order.payment.service_fee_amount_guest_cents
            assert_equal 500, order.payment.service_fee_amount_host_cents
          end
        end

        protected

        def form_configuration
          @form_configuration ||= FactoryGirl.create(
            :form_configuration,
            name: 'checkout_form',
            base_form: 'CheckoutForm',
            configuration: {
              payment: {
                validation: { presence: true },
                company_id: { validation: { presence: true } },
                payment_method_id: { property_options: {
                  default: @payment_method.id,
                  readonly: true
                } },
                credit_card_token: { validation: { presence: true } }
              }

            }
          )
        end

        def stripe_customer_json
          {
            "id": 'cus_AdXsZs1LwO6UjG',
            "object": 'customer',
            "account_balance": 0,
            "created": 1_494_507_189,
            "currency": 'usd',
            "default_source": 'card_1AIGn22eZvKYlo2CW5ie93yI',
            "delinquent": false,
            "description": '1',
            "discount": nil,
            "email": nil,
            "livemode": false,
            "metadata": {
            },
            "shipping": nil,
            "sources": {
              "object": 'list',
              "data": [
                {
                  "id": 'card_1AIGn22eZvKYlo2CW5ie93yI',
                  "object": 'card',
                  "address_city": nil,
                  "address_country": nil,
                  "address_line1": nil,
                  "address_line1_check": nil,
                  "address_line2": nil,
                  "address_state": nil,
                  "address_zip": nil,
                  "address_zip_check": nil,
                  "brand": 'Visa',
                  "country": 'US',
                  "customer": 'cus_AdXsZs1LwO6UjG',
                  "cvc_check": 'pass',
                  "dynamic_last4": nil,
                  "exp_month": 2,
                  "exp_year": 2021,
                  "fingerprint": 'Xt5EWLLDS7FJjR1c',
                  "funding": 'credit',
                  "last4": '4242',
                  "metadata": {
                  },
                  "name": nil,
                  "tokenization_method": nil
                }
              ],
              "has_more": false,
              "total_count": 1,
              "url": '/v1/customers/cus_AdXsZs1LwO6UjG/sources'
            },
            "subscriptions": {
              "object": 'list',
              "data": [

              ],
              "has_more": false,
              "total_count": 0,
              "url": '/v1/customers/cus_AdXsZs1LwO6UjG/subscriptions'
            }
          }.to_json
        end

        def stripe_charge_json
          {
            "id": 'ch_1AIGq22eZvKYlo2CycYiMyEs',
            "object": 'charge',
            "amount": 10_000,
            "amount_refunded": 0,
            "application": nil,
            "application_fee": nil,
            "balance_transaction": 'txn_1AIGq22eZvKYlo2CbdFGDiJ9',
            "captured": true,
            "created": 1_494_507_374,
            "currency": 'usd',
            "customer": nil,
            "description": 'Ad posting balance recharge of $100 for PremierAuto [reshma.s+755@geazy.com]',
            "destination": nil,
            "dispute": nil,
            "failure_code": nil,
            "failure_message": nil,
            "fraud_details": {
            },
            "invoice": nil,
            "livemode": false,
            "metadata": {
            },
            "on_behalf_of": nil,
            "order": nil,
            "outcome": {
              "network_status": 'approved_by_network',
              "reason": nil,
              "risk_level": 'normal',
              "seller_message": 'Payment complete.',
              "type": 'authorized'
            },
            "paid": true,
            "receipt_email": nil,
            "receipt_number": nil,
            "refunded": false,
            "refunds": {
              "object": 'list',
              "data": [

              ],
              "has_more": false,
              "total_count": 0,
              "url": '/v1/charges/ch_1AIGq22eZvKYlo2CycYiMyEs/refunds'
            },
            "review": nil,
            "shipping": nil,
            "source": {
              "id": 'card_1AIGq22eZvKYlo2C5o4gEdQ1',
              "object": 'card',
              "address_city": nil,
              "address_country": nil,
              "address_line1": nil,
              "address_line1_check": nil,
              "address_line2": nil,
              "address_state": nil,
              "address_zip": nil,
              "address_zip_check": nil,
              "brand": 'Visa',
              "country": 'US',
              "customer": nil,
              "cvc_check": 'pass',
              "dynamic_last4": nil,
              "exp_month": 5,
              "exp_year": 2025,
              "fingerprint": 'Xt5EWLLDS7FJjR1c',
              "funding": 'credit',
              "last4": '4242',
              "metadata": {
              },
              "name": nil,
              "tokenization_method": nil
            },
            "source_transfer": nil,
            "statement_descriptor": nil,
            "status": 'succeeded',
            "transfer_group": nil
          }.to_json
        end
      end
    end
  end
end
