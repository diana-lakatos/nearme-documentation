# frozen_string_literal: true
require 'test_helper'

class Webhooks::StripeConnectsControllerTest < ActionController::TestCase
  context '#index' do
    setup do
      MerchantAccount::StripeConnectMerchantAccount.any_instance.stubs(:onboard!).returns(true)
      Stripe::BalanceTransaction.stubs(:all).returns(transaction_balance)
      @company = FactoryGirl.create(:company)
      @payment_gateway = FactoryGirl.create(:stripe_connect_payment_gateway)
      @merchant_account = FactoryGirl.create(:stripe_connect_merchant_account, external_id: 'xyz', payment_gateway: @payment_gateway, merchantable: @company)
    end

    context '#webhook' do
      should 'mark payment_transfer as transferred on transfer.paid webhook' do
        payment_transfer = FactoryGirl.create(:payment_transfer_unpaid, payment_gateway: @payment_gateway)
        event_options = { type: 'transfer.updated', id: payment_transfer.token, status: 'paid' }

        Stripe::Event.stubs(:retrieve).returns(event_response(event_options))

        assert_difference 'Webhook.count' do
          post :webhook, id: event_response(event_options).id
        end

        payment_transfer.reload
        assert :success
        assert payment_transfer.transferred?
        assert payment_transfer.payout_attempts.first.success?
      end

      should 'mark payment_transfer as failed on transfer.failed webhook' do
        payment_transfer = FactoryGirl.create(:payment_transfer_unpaid, payment_gateway: @payment_gateway)
        event_options = { type: 'transfer.updated', id: payment_transfer.token, status: 'failed' }

        Stripe::Event.stubs(:retrieve).returns(event_response(event_options))

        assert_difference 'Webhook.count' do
          post :webhook, id: event_response(event_options).id
        end

        payment_transfer.reload
        assert :success
        refute payment_transfer.transferred?
        refute payment_transfer.payout_attempts.first.success?
      end

      should 'create transfers with given payments' do
        @payments = []
        %w(ch_19227cHEiLsRDx9fwsAV7Ahx ch_20227cHEiLsRDx9fwsAV7Ahy).each do |payment_token|
          @payments << FactoryGirl.create(:paid_payment, payment_method: @payment_gateway.payment_methods.first,
                                                         external_id: payment_token,
                                                         company: @company,
                                                         merchant_account: @merchant_account)
        end

        %w(pending paid failed).each do |transfer_state|
          event_options = {
            type: 'transfer.created',
            id: "transfer_#{transfer_state}_xyz",
            status: transfer_state,
            payments: @payments.map { |p| { id: p.external_id } }
          }
          Stripe::Event.stubs(:retrieve).returns(event_response(event_options))

          assert_difference ['@payment_gateway.payment_transfers.count', '@payment_gateway.webhooks.count'] do
            post :webhook, id: event_response(event_options).id, user_id: @merchant_account.external_id
          end

          @payment_transfer = PaymentTransfer.last
          assert_equal @payment_transfer.payments.sort_by(&:id), @payments.sort_by(&:id)
          assert_equal @payment_transfer.company, @company
          assert @payment_transfer.send("#{transfer_state}?")

          assert_no_difference '@payment_gateway.payment_transfers.count' do
            post :webhook, id: event_response(event_options).id
          end
        end
      end
    end
  end

  def event_response(options)
    OpenStruct.new(
      "created": 1_326_853_478,
      "livemode": false,
      "id": "evt_#{Random.new_seed}",
      "type": options[:type],
      "object": 'event',
      "request": nil,
      "pending_webhooks": 1,
      "api_version": '2013-12-03',
      "data": transfer_response(options)
    )
  end

  def transfer_response(options)
    OpenStruct.new(
      "object": OpenStruct.new(
        "id": options[:id],
        "status": options[:status],
        "object": 'transfer',
        "amount": 40_000,
        "amount_reversed": 0,
        "application_fee": nil,
        "balance_transaction": 'txn_00000000000000',
        "created": 1_471_221_734,
        "currency": 'usd',
        "date": 1_471_221_734,
        "description": nil,
        "destination": 'acct_18hINjGEA1M7E9gL',
        "destination_payment": 'py_18iZBCGEA1M7E9gLtGXsXigx',
        "failure_code": nil,
        "failure_message": nil,
        "livemode": false,
        "metadata": {},
        "recipient": nil,
        "reversals": OpenStruct.new(
          "object": 'list',
          "count": 0,
          "data": [],
          "has_more": false,
          "total_count": 0,
          "url": '/v1/transfers/tr_18iZBC2NyQr8dJTtiVOMXN5y/reversals'
        ),
        "transactions": OpenStruct.new(
          "object": 'list',
          "count": 2,
          "data": (options[:payments] || []).map { |payment_options| charge_response(payment_options) }
        ),
        "reversed": false,
        "source_transaction": 'ch_18iZBA2NyQr8dJTtumqma5cX',
        "source_type": 'card',
        "statement_descriptor": nil,
        "type": 'stripe_account',
        "account": nil
      )
    )
  end

  def charge_response(options)
    OpenStruct.new(
      id: options[:id],
      amount: 48_400,
      created: 1_475_861_220,
      currency: 'usd',
      customer_details: 'Merchant Nam',
      description: nil,
      fee: 10_234,
      net: 38_166,
      type: 'charge'
    )
  end

  def transaction_balance
    OpenStruct.new(object: 'list',
                   data: [
                     OpenStruct.new(source: 'ch_19227cHEiLsRDx9fwsAV7Ahx',
                                    type: 'charge'),
                     OpenStruct.new(source: 'ch_20227cHEiLsRDx9fwsAV7Ahy',
                                    type: 'charge'),
                     OpenStruct.new(source: 'tr_xyz',
                                    type: 'transfer')
                   ],
                   has_more: false,
                   url: '/v1/balance/history')
  end
end
