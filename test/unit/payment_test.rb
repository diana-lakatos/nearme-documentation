# frozen_string_literal: true
require 'test_helper'

class PaymentTest < ActiveSupport::TestCase
  context 'manual payment' do
    setup do
      @manual_payment = FactoryGirl.build(:manual_payment, state: 'paid')
    end

    should 'should not be refunded' do
      refute @manual_payment.send(:refund!, @manual_payment.total_amount_cents)
      assert @manual_payment.paid?
    end
  end

  context 'direct token' do
    should 'be generated when gateway is set to direct mode' do
      token = 'TOKEN'
      @payment_gateway = FactoryGirl.build :stripe_connect_payment_gateway, config: { "settings" => { "charge_type" => 'direct' }}
      @payment_source = FactoryGirl.build(:credit_card)
      @payment_source.stubs(:customer_id).returns('CustomerID')

      @payment = FactoryGirl.build(:pending_payment,
				   payment_method: @payment_gateway.payment_methods.credit_card.first,
				   payment_source: @payment_source			  )
      @payment.stubs(:payment_gateway).returns(@payment_gateway)
      @payment.stubs(:merchant_id).returns('MerchantID')
      @payment_gateway.stubs(:create_token).returns(OpenStruct.new(id: token))
      assert_equal token, @payment.direct_token
      assert @payment.direct_charge?
    end
  end

  context 'pending payment' do
    setup do
      @payment = FactoryGirl.create(:pending_payment)
    end

    should 'raise validation errors on credit card on authorize' do
      stub_active_merchant_interaction
      @payment.payment_source = FactoryGirl.build(:invalid_credit_card_attributes)
      refute @payment.process!
      assert_equal [I18n.t('buy_sell_market.checkout.invalid_cc')], @payment.payment_source.errors[:base]
    end

    should 'be authorized correctly when CC is valid' do
      stub_active_merchant_interaction
      @payment.credit_card = FactoryGirl.build(:credit_card_attributes)
      assert @payment.authorize!
      assert @payment.valid?
      assert @payment.successful_billing_authorization.present?
      assert_equal(
        OpenStruct.new(authorization: '54533', success?: true),
        @payment.successful_billing_authorization.response
      )
      assert_equal '54533', @payment.external_id
    end

    should 'not authorize when authorization response is not success' do
      stub_active_merchant_interaction(success?: false, message: 'fail')
      @payment.credit_card_attributes = FactoryGirl.attributes_for(:credit_card_attributes)
      refute @payment.authorize!
      billing_authorization = @payment.billing_authorizations.last
      assert @payment.errors.present?
      assert_equal @payment.payment_gateway, billing_authorization.payment_gateway
      assert_equal billing_authorization.success?, false
      assert_equal(billing_authorization.response, OpenStruct.new(authorization: '54533', success?: false, message: 'fail'))
    end

    should 'display internal error message to gateway user' do
      response = OpenStruct.new(code: '500', message: 'Internal server error')
      @payment.payment_gateway.gateway.stubs(:authorize).raises(ResponseError.new(response))
      @payment.credit_card_attributes = FactoryGirl.attributes_for(:credit_card_attributes)
      refute @payment.authorize!
      assert @payment.errors[:base].include?('Failed with 500 Internal server error')
    end
  end

  SUCCESS_RESPONSE = { 'paid_amount' => '10.00' }.freeze
  SUCCESS_RESPONSE_WITH_TRANSACTION = { 'paid_amount' => '10.00', 'balance_transaction' => '1234' }.freeze
  FAILURE_RESPONSE = { 'paid_amount' => '10.00', 'error' => 'fail' }.freeze

  context 'authorized payment' do
    setup do
      @company = FactoryGirl.build(:company)
      @payment = FactoryGirl.build(:authorized_payment, company: @company)
      @host = @payment.payable.owner
    end

    should 'return on refund if payment was not paid' do
      PaymentGateway.any_instance.expects(:refund).never
      @payment.update_attribute(:paid_at, nil)
      @payment.refund!(@payment.total_amount_cents)
      refute @payment.reload.refunded?
    end

    should 'charge when payment gateway worked' do
      stub_active_merchant_interaction(success?: true, params: SUCCESS_RESPONSE)
      assert @payment.capture!
      assert @payment.paid?
      charge = Charge.last
      assert charge.success?
      assert_equal SUCCESS_RESPONSE, charge.response.params
    end

    should 'charge when payment gateway with direct_charge' do
      PaymentGateway.any_instance.stubs(:direct_charge?).returns(true)
      stub_active_merchant_interaction(success?: true, params: SUCCESS_RESPONSE_WITH_TRANSACTION)
      assert @payment.capture!
      assert @payment.paid?
      charge = Charge.last
      assert charge.success?
      assert_equal SUCCESS_RESPONSE_WITH_TRANSACTION, charge.response.params
    end

    should 'not charge when payment gateway fails' do
      stub_active_merchant_interaction(success?: false, params: FAILURE_RESPONSE)
      refute @payment.capture!
      refute @payment.paid?
      charge = Charge.last
      refute charge.success?
      assert_equal FAILURE_RESPONSE, charge.response.params
    end

    should 'not capture while Internal Gateway error is raised' do
      response = OpenStruct.new(code: '500', message: 'Internal server error')
      @payment.payment_gateway.gateway.stubs(:capture).raises(ResponseError.new(response))
      @payment.credit_card_attributes = FactoryGirl.attributes_for(:credit_card_attributes)
      refute @payment.capture!
      assert @payment.errors.full_messages.include?('Failed with 500 Internal server error')
      refute @payment.paid?
    end

    should 'require transfer for imediate payment' do
      @payment.stubs(:immediate_payout?).returns(false)
      refute @payment.send(:should_create_transfer?)

      @payment.stubs(:immediate_payout?).returns(true)
      assert @payment.send(:should_create_transfer?)

      @payment.stubs(:direct_charge?).returns(true)
      refute @payment.send(:should_create_transfer?)
    end

    should 'create transfer for successful imediate payment' do
      stub_active_merchant_interaction(success?: true, params: SUCCESS_RESPONSE)
      @payment.stubs(:immediate_payout?).returns(true)
      assert @payment.capture!
      assert_equal [@payment], PaymentTransfer.last.payments
    end
  end

  context 'paid payment' do
    setup do
      @payment = FactoryGirl.create(:paid_payment)
    end

    should 'find the right charge if there were failing attempts' do
      stub_active_merchant_interaction
      FactoryGirl.create(:charge, payment: @payment, success: false, response: { id: 'id' })
      @payment.refund!(@payment.total_amount_cents)
      assert @payment.reload.refunded?
    end

    should 'not be refunded if failed' do
      PaymentGateway::StripePaymentGateway.any_instance.expects(:gateway_refund).times(3).returns(Refund.new(success: false))
      refute @payment.refund!(@payment.total_amount_cents)

      stub_active_merchant_interaction
      @payment.stubs(:immediate_payout?).returns(true)
      assert @payment.refund!(@payment.total_amount_cents)
    end

    should 'not be refunded if paid out' do
      @payment.company = FactoryGirl.create(:company)
      @payment.save!
      @payment.company.schedule_payment_transfer
      @payment.reload.payment_transfer.touch(:transferred_at)
      refute @payment.refund!(@payment.total_amount_cents)
    end

    context 'advanced cancellation policy penalty' do
      setup do
        @payment.update_attribute(:cancellation_policy_penalty_percentage, 60)
        @payment.update_attribute(:total_amount_cents, 1100)
        @payment.update_attribute(:subtotal_amount_cents, 1000)
        @payment.update_attribute(:service_fee_amount_guest_cents, 100)
        @payment.update_attribute(:service_fee_amount_host_cents, 150)
      end

      should 'not refund while Internal Gateway error is raised' do
        response = OpenStruct.new(code: '500', message: 'Internal server error')
        ActiveMerchant::Billing::StripeGateway.any_instance.stubs(:refund).raises(ResponseError.new(response))

        refute @payment.refund!(@payment.total_amount_cents)
        assert @payment.paid?
        assert_equal 3, @payment.refunds.where(success: false).count
        refund_response = OpenStruct.new(success?: false, message: 'Failed with 500 Internal server error')
        assert_equal refund_response, @payment.refunds.last.response
      end
    end

    context 'cancelation policy penalty' do
      setup do
        @payment.update_attribute(:cancellation_policy_penalty_percentage, 60)
      end

      should 'return have subtotal amount after refund equal to subtotal amount if no refund has been made' do
        assert_equal 10_000, @payment.transfer_amount_cents
      end

      should 'trigger refund method with proper amount when guest cancels ' do
        @payment.payable.update_column(:state, 'cancelled_by_guest')
        PaymentGateway::StripePaymentGateway.any_instance.expects(:refund).once.with do |amount, _reference, _response|
          amount == 4000
        end.returns(Refund.new(success: true))
        @payment.refund!(4000)
      end

      should 'trigger refund method with proper amount when host cancels ' do
        @payment.payable.update_column(:state, 'cancelled_by_host')
        PaymentGateway::StripePaymentGateway.any_instance.expects(:refund).once.with do |amount, _reference, _response|
          amount == 11_000
        end.returns(Refund.new(success: true))
        @payment.refund!(11_000)
      end

      should 'calculate proper subtotal amount cents after refund once refund has been issued' do
        @refund = FactoryGirl.create(:refund, payment: @payment, amount_cents: 3000)
        assert_equal @payment.subtotal_amount_cents - 3000, @payment.transfer_amount_cents
      end
    end
  end

  context 'refunded payment' do
    setup do
      stub_active_merchant_interaction
      @payment = FactoryGirl.create(:refunded_payment)
    end

    should 'return if payment was already refunded' do
      PaymentGateway.any_instance.expects(:refund).never
      @payment.refund!(100)
    end
  end

  context 'foreign keys' do
    setup do
      @reservation = FactoryGirl.create(:reservation)
      @reservation.payment.destroy
      @payment = @reservation.build_payment(@reservation.shared_payment_attributes.merge(payment_method: FactoryGirl.create(:credit_card_payment_method),
                                                                                         credit_card_attributes: FactoryGirl.attributes_for(:credit_card_attributes)))
      @payment.save!
    end

    should 'assign correct key immediately' do
      assert @payment.company_id.present?
      assert_equal @payment.company_id, @payment.payable.company_id
    end
  end
end

class ResponseError < StandardError # :nodoc:
  attr_reader :response

  def initialize(response, message = nil)
    @response = response
    @message  = message
  end

  def to_s
    "Failed with #{response.code} #{response.message if response.respond_to?(:message)}"
  end
end
