require 'test_helper'

class Webhooks::StripeConnectsControllerTest < ActionController::TestCase
  context '#index' do
    setup do
      @company = FactoryGirl.create(:company)
      @payment_gateway = FactoryGirl.create(:stripe_connect_payment_gateway)
    end

    context '#webhook' do
      should 'mark payment_transfer as transferred on transfer.paid webhook' do
        payment_transfer = FactoryGirl.create(:payment_transfer_unpaid, payment_gateway: @payment_gateway)
        event_options = { type: 'transfer.updated', id: payment_transfer.token, status: 'paid' }

        Stripe::Event.stubs(:retrieve).returns(event_object(event_options))

        assert_difference 'Webhook.count' do
          post :webhook, id: event_object(event_options).id
        end

        payment_transfer.reload
        assert :success
        assert payment_transfer.transferred?
        assert payment_transfer.payout_attempts.first.success?
      end

      should 'mark payment_transfer as failed on transfer.failed webhook' do
        payment_transfer = FactoryGirl.create(:payment_transfer_unpaid, payment_gateway: @payment_gateway)
        event_options = { type: 'transfer.updated', id: payment_transfer.token, status: 'failed' }

        Stripe::Event.stubs(:retrieve).returns(event_object(event_options))

        assert_difference 'Webhook.count' do
          post :webhook, id: event_object(event_options).id
        end

        payment_transfer.reload
        assert :success
        refute payment_transfer.transferred?
        refute payment_transfer.payout_attempts.first.success?
      end
    end
  end

  def event_object(options)
    OpenStruct.new("created": 1_326_853_478,
                   "livemode": false,
                   "id": 'evt_00000000000000',
                   "type": options[:type],
                   "object": 'event',
                   "request": nil,
                   "pending_webhooks": 1,
                   "api_version": '2013-12-03',
                   "data": OpenStruct.new("object": OpenStruct.new("id": options[:id],
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
                                                                   "reversals": OpenStruct.new("object": 'list',
                                                                                               "count": 0,
                                                                                               "data": [],
                                                                                               "has_more": false,
                                                                                               "total_count": 0,
                                                                                               "url": '/v1/transfers/tr_18iZBC2NyQr8dJTtiVOMXN5y/reversals'),
                                                                   "reversed": false,
                                                                   "source_transaction": 'ch_18iZBA2NyQr8dJTtumqma5cX',
                                                                   "source_type": 'card',
                                                                   "statement_descriptor": nil,
                                                                   "status": options[:status],
                                                                   "type": 'stripe_account',
                                                                   "account": nil)))
  end
end
