# frozen_string_literal: true
require 'test_helper'
require 'stripe'

class Webhooks::StripeControllerTest < ActionController::TestCase
  context '#index' do
    VERSION_1 = '2013-12-03'
    VERSION_2 = '2017-04-06'
    VERSION_3 = '2017-05-25'

    CHARGE_ID_1 = 'ch_19227cHEiLsRDx9fwsAV7Ahx'
    CHARGE_ID_2 = 'ch_20227cHEiLsRDx9fwsAV7Ahy'

    DISABLED_REASON = 'rejected_fraud'
    DISABLED_REASON_MESSAGE = 'This account is rejected due to suspected fraud or illegal activity.'
    setup do
      MerchantAccount::StripeConnectMerchantAccount.any_instance.stubs(:onboard!).returns(true)
      @company = FactoryGirl.create(:company)
      @payment_gateway = FactoryGirl.create(:stripe_connect_payment_gateway)
      @webhook_configuration = @payment_gateway.webhook_configurations.create(signing_secret: "xxx")
    end

    context 'account webhooks' do
      should 'verify merchant account' do
        @merchant_account = FactoryGirl.create(:stripe_connect_merchant_account, external_id: 'xyz', payment_gateway: @payment_gateway, merchantable: @company, state: "pending")
        refute @merchant_account.verified?

        WorkflowStepJob.expects(:perform).with(WorkflowStep::PaymentGatewayWorkflow::MerchantAccountApproved, @merchant_account.id)

        event = build_event('account.updated', { transfers_enabled: true }, version: VERSION_3)
        assert_difference ['Webhook.count'] do
          @request.env["HTTP_STRIPE_SIGNATURE"] = webhook_header(@webhook_configuration, event)
          post :webhook, event.to_json, webhook_configuration_id: @webhook_configuration.id
        end

        assert @merchant_account.reload.verified?
      end

      should 'send incomplete merchant account workflow' do
        @merchant_account = FactoryGirl.create(:stripe_connect_merchant_account, external_id: 'xyz', payment_gateway: @payment_gateway, merchantable: @company, state: "pending")
        refute @merchant_account.verified?

        WorkflowStepJob.expects(:perform).with(WorkflowStep::PaymentGatewayWorkflow::MerchantAccountPending, @merchant_account.id)

        verification = { due_by: nil, details_code: nil, fields_needed: ['legal_entity.address'], disabled_reason: DISABLED_REASON }
        event = build_event('account.updated', { transfers_enabled: false, verification: verification }, version: VERSION_3)
        assert_difference ['Webhook.count'] do
          @request.env["HTTP_STRIPE_SIGNATURE"] = webhook_header(@webhook_configuration, event)
          post :webhook, event.to_json, webhook_configuration_id: @webhook_configuration.id
        end

        assert @merchant_account.reload.pending?
        assert @merchant_account.to_liquid.all_errors.include?(DISABLED_REASON_MESSAGE)
      end

      should 'fail previously verified account' do
        @merchant_account = FactoryGirl.create(:stripe_connect_merchant_account, external_id: 'xyz', payment_gateway: @payment_gateway, merchantable: @company)
        assert @merchant_account.verified?

        WorkflowStepJob.expects(:perform).with(WorkflowStep::PaymentGatewayWorkflow::MerchantAccountDeclined, @merchant_account.id)

        verification = { due_by: nil, details_code: nil, fields_needed: ['legal_entity.address'], disabled_reason: DISABLED_REASON }
        event = build_event('account.updated', { transfers_enabled: false, verification: verification }, version: VERSION_3)
        assert_difference ['Webhook.count'] do
          @request.env["HTTP_STRIPE_SIGNATURE"] = webhook_header(@webhook_configuration, event)
          post :webhook, event.to_json, webhook_configuration_id: @webhook_configuration.id
        end

        assert @merchant_account.reload.failed?
        assert @merchant_account.to_liquid.all_errors.include?(DISABLED_REASON_MESSAGE)
      end

      should 'fail delivering webhook when account not found' do
        @merchant_account = FactoryGirl.create(:stripe_connect_merchant_account, external_id: 'xyz', payment_gateway: @payment_gateway, state: 'pending')
        event = build_event('account.updated', {}, user_id: 'zxy', account: 'zxy', version: VERSION_3)
        assert_raises(ActiveRecord::RecordNotFound) do
          @request.env["HTTP_STRIPE_SIGNATURE"] = webhook_header(@webhook_configuration, event)
          post :webhook, event.to_json, webhook_configuration_id: @webhook_configuration.id
        end
        assert @merchant_account.reload.pending?
      end
    end

    context 'transfer webhooks' do
      setup do
        @merchant_account = FactoryGirl.create(:stripe_connect_merchant_account, external_id: 'xyz', payment_gateway: @payment_gateway, merchantable: @company)
      end

      context '#VERSION_2' do
        should 'raise error when secret changed' do
          event = build_event('payout.created', 'pending', version: VERSION_2)
          @webhook_configuration.signing_secret = 'fake_secret'
          assert_no_difference ['Webhook.count'] do
            @request.env["HTTP_STRIPE_SIGNATURE"] = webhook_header(@webhook_configuration, event)
            post :webhook, event.to_json, webhook_configuration_id: @webhook_configuration.id
          end
          assert response.status.equal?(400)
        end

        should 'process trasfer update as in V1 for non direct charge' do
          Stripe::BalanceTransaction.stubs(:all).returns(FactoryGirl.build(:stripe_balance_transaction_all, data: [
            FactoryGirl.build(:stripe_payment_balance_transaction, source: CHARGE_ID_1),
          ]))

          Stripe::Charge.stubs(:retrieve).returns(FactoryGirl.build(:stripe_charge, source_transfer: 'paid_xyz' ) )

          update_transfer_webhook_check('payout.paid', 'paid', version: VERSION_2)
        end

        should 'process trasfer update as in V1' do
          update_transfer_webhook_check('transfer.paid', 'paid', version: VERSION_2)
        end

        should 'process pyout webhooks for pending payout' do
          create_transfer_webhook_check('payout.created', 'pending', version: VERSION_2)
        end

        should 'process pyout webhooks for failed
         payout' do
          create_transfer_webhook_check('payout.created', 'failed', version: VERSION_2)
        end
      end

      context '#VERSION_1' do
        should 'mark payment_transfer as paid on transfer.paid webhook' do
          update_transfer_webhook_check('transfer.paid', 'paid')
        end

        should 'mark payment_transfer as paid on transfer.updated webhook' do
          update_transfer_webhook_check('transfer.updated', 'paid')
        end

        should 'mark payment_transfer as failed on transfer.updated webhook' do
          update_transfer_webhook_check('transfer.updated', 'failed')
        end

        should 'mark payment_transfer as failed on transfer.failed webhook' do
          update_transfer_webhook_check('transfer.failed', 'failed')
        end

        should 'create transfers with given payments after transfer.pending webhook' do
          create_transfer_webhook_check('transfer.created', 'pending')
        end

        should 'create transfers with given payments after transfer.paid webhook' do
          create_transfer_webhook_check('transfer.created', 'paid')
        end

        should 'create transfers with given payments after transfer.failed webhook' do
          create_transfer_webhook_check('transfer.created', 'failed')
        end
      end
    end
  end

  def update_transfer_webhook_check(webhook, state, event_options={} )
    payment_transfer = FactoryGirl.create(:payment_transfer_unpaid, payment_gateway: @payment_gateway, token: "#{state}_xyz")
    event = build_event(webhook, state, event_options)

    assert_difference ['@payment_gateway.webhooks.count'] do
      @request.env["HTTP_STRIPE_SIGNATURE"] = webhook_header(@webhook_configuration, event)
      post :webhook, event.to_json, webhook_configuration_id: @webhook_configuration.id
    end
    assert :success

    payment_transfer.reload
    if state == 'paid'
      assert payment_transfer.transferred?
    else
      refute payment_transfer.transferred?
    end
    assert payment_transfer.send("#{state}?")
  end

  def create_transfer_webhook_check(webhook, state, event_options={} )
    PaymentGateway::StripeConnectPaymentGateway.any_instance.stubs(:direct_charge?).returns(true)
    @payments = []
    [CHARGE_ID_1, CHARGE_ID_2].each do |payment_token|
      @payments << FactoryGirl.create(:paid_payment, payment_method: @payment_gateway.payment_methods.first,
                                                     external_id: payment_token,
                                                     company: @company,
                                                     merchant_account: @merchant_account)
    end

    Stripe::BalanceTransaction.stubs(:all).returns(FactoryGirl.build(:stripe_balance_transaction_all, data: [
      FactoryGirl.build(:stripe_charge_balance_transaction, source: CHARGE_ID_1),
      FactoryGirl.build(:stripe_charge_balance_transaction, source: CHARGE_ID_2)
    ]))

    event = build_event(webhook, state, event_options)

    assert_difference ['@payment_gateway.reload.payment_transfers.count', '@payment_gateway.webhooks.count'] do
      @request.env["HTTP_STRIPE_SIGNATURE"] = webhook_header(@webhook_configuration, event)
      post :webhook, event.to_json, webhook_configuration_id: @webhook_configuration.id
    end
    assert :success
    @payment_transfer = PaymentTransfer.last
    assert_equal @payment_transfer.payments.sort_by(&:id), @payments.sort_by(&:id)
    assert_equal @payment_transfer.company, @company
    assert @payment_transfer.send("#{state}?")

    assert_no_difference '@payment_gateway.payment_transfers.count' do
      @request.env["HTTP_STRIPE_SIGNATURE"] = webhook_header(@webhook_configuration, event)
      post :webhook, event.to_json, webhook_configuration_id: @webhook_configuration.id
    end
  end

  def build_event(webhook, object_options, event_options)
    object_options = { id: "#{object_options}_xyz", status: object_options } if object_options.instance_of?(String)
    FactoryGirl.build(:stripe_event,
      api_version: event_options[:version] || VERSION_1,
      type: webhook,
      data: { object: FactoryGirl.build("stripe_#{webhook.split('.').first}", object_options) },
      user_id: event_options[:user_id] || @merchant_account.external_id,
      account: event_options[:account] || @merchant_account.external_id
    )
  end

  def webhook_header(webhook_configuration, event)
    timestamp = Time.zone.now.to_i
    sig = calculate_signature(event.to_json, webhook_configuration.signing_secret, timestamp)

    "t=#{timestamp},v1=#{sig},v0=#{sig}"
  end

  def calculate_signature(payload, secret, timestamp)
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret, "#{timestamp}.#{payload}")
  end

end
