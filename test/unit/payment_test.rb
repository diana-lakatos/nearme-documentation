require 'test_helper'

class PaymentTest < ActiveSupport::TestCase

  context 'manual payment' do
    setup do
      @manual_payment = FactoryGirl.build(:manual_payment, state: 'paid')
    end

    should 'should not be refunded' do
      Payment.any_instance.expects(:refund).never
      @manual_payment.send(:attempt_payment_refund)
      assert @manual_payment.paid?
    end
  end

  context "pending payment" do
    setup do
      stub_active_merchant_interaction
      @payment = FactoryGirl.create(:pending_payment)
    end

    should 'raise validation errors on credit card on authorize' do
      refute @payment.authorize
      assert_equal [I18n.t('buy_sell_market.checkout.invalid_cc')], @payment.errors[:cc]
    end

    should 'be authorized correctly when CC is valid' do
      @payment.credit_card_form = FactoryGirl.attributes_for(:credit_card_form)
      assert @payment.authorize
      assert @payment.valid?
      assert @payment.successful_billing_authorization.present?
      assert_equal(
        OpenStruct.new(authorization: "54533", success?: true),
        @payment.successful_billing_authorization.response
      )
    end

    should "not authorize when authorization response is not success" do
      stub_active_merchant_interaction({success?: false, message: "fail"})
      @payment.credit_card_form = FactoryGirl.attributes_for(:credit_card_form)
      refute @payment.authorize
      billing_authorization = @payment.billing_authorizations.last
      assert_equal true, @payment.errors.present?
      assert_equal @payment.payment_gateway, billing_authorization.payment_gateway
      assert_equal billing_authorization.success?, false
      assert_equal(billing_authorization.response, OpenStruct.new(authorization: "54533", success?: false, message: 'fail'))
    end
  end

  SUCCESS_RESPONSE = {"paid_amount"=>"10.00"}
  FAILURE_RESPONSE = {"paid_amount"=>"10.00", "error"=>"fail"}

  context 'authorized payment' do
    setup do
      stub_active_merchant_interaction({success?: true, params: SUCCESS_RESPONSE })
      @payment = FactoryGirl.create(:authorized_payment)
      @host = @payment.payable.owner
    end

    should 'return on refund if payment was not paid' do
      PaymentGateway.any_instance.expects(:refund).never
      @payment.update_attribute(:paid_at, nil)
      @payment.refund!
      refute @payment.reload.refunded?
    end

    should 'track charge in mixpanel after successful creation' do
      ReservationChargeTrackerJob.expects(:perform_later).with(@payment.payable.date.end_of_day, @payment.payable.id).once
      assert @payment.capture!
      assert_equal @payment.total_amount_cents, @payment.charges.last.amount
      assert @payment.charges.last.success
      assert @payment.paid?

      charge = Charge.last
      assert charge.success?
      assert_equal @host.id, charge.user_id
      assert_equal 110_00, charge.amount
      assert_equal 'USD', charge.currency
      assert_equal SUCCESS_RESPONSE, charge.response.params
      assert_equal @payment, charge.payment
    end

    should 'not charge when payment gateway fails' do
      stub_active_merchant_interaction({success?: false, params: FAILURE_RESPONSE })
      refute @payment.capture!
      refute @payment.paid?
      charge = Charge.last
      refute charge.success?
      assert_equal FAILURE_RESPONSE, charge.response.params
    end
  end

  context 'paid payment' do
    setup do
      stub_active_merchant_interaction
      @payment = FactoryGirl.create(:paid_payment)
    end

    should 'find the right charge if there were failing attempts' do
      FactoryGirl.create(:charge, payment: @payment, success: false, response: { id: "id" })
      @payment.refund!
      assert @payment.reload.refunded?
    end

    should 'not be refunded if failed' do
      PaymentGateway::StripePaymentGateway.any_instance.expects(:gateway_refund).returns(Refund.new(:success => false))
      @payment.refund!
      refute @payment.reload.refunded?
    end

    context 'advanced cancellation policy penalty' do
      setup do
        @payment.update_attribute(:cancellation_policy_penalty_percentage, 60)
        @payment.update_attribute(:subtotal_amount_cents, 1000)
        @payment.update_attribute(:service_fee_amount_guest_cents, 100)
        @payment.update_attribute(:service_fee_amount_host_cents, 150)
      end

      should 'refund proper amount when guest cancels' do
        @payment.payable.update_column(:state, 'cancelled_by_guest')
        assert_equal 1000, @payment.subtotal_amount_cents
        assert_equal 400, @payment.amount_to_be_refunded
        @payment.refund!
        assert @payment.reload.refunded?
        assert_equal 0, @payment.final_service_fee_amount_host_cents
        assert_equal 100, @payment.final_service_fee_amount_guest_cents
        assert_equal 600, @payment.subtotal_amount_cents_after_refund
        assert_equal 400, @payment.refunds.last.amount
      end

      should 'refund proper amount when host cancels' do
        @payment.payable.update_column(:state, 'cancelled_by_host')
        assert_equal 1000, @payment.subtotal_amount_cents
        assert_equal 1100, @payment.amount_to_be_refunded
        @payment.refund!
        assert @payment.reload.refunded?
        assert_equal 0, @payment.final_service_fee_amount_host_cents
        assert_equal 0, @payment.final_service_fee_amount_guest_cents
        assert_equal 0, @payment.subtotal_amount_cents_after_refund
        assert_equal 1100, @payment.refunds.last.amount
      end
    end

    context 'cancelation policy penalty' do

      setup do
        @payment.update_attribute(:cancellation_policy_penalty_percentage, 60)
      end

      should 'return have subtotal amount after refund equal to subtotal amount if no refund has been made' do
        assert_equal 10000, @payment.subtotal_amount_cents_after_refund
      end

      should 'calculate proper number for amount_to_be_refunded if cancelled by guest' do
        @payment.payable.update_column(:state, 'cancelled_by_guest')
        assert_equal 10000, @payment.subtotal_amount_cents
        assert_equal 4000, @payment.amount_to_be_refunded
      end

      should 'calculate proper number for amount_to_be_refunded if cancelled by host' do
        @payment.payable.update_column(:state, 'cancelled_by_host')
        assert_equal 10000, @payment.subtotal_amount_cents
        assert_equal 11000, @payment.amount_to_be_refunded
      end

      should 'trigger refund method with proper amount when guest cancels ' do
        @payment.payable.update_column(:state, 'cancelled_by_guest')
        PaymentGateway::StripePaymentGateway.any_instance.expects(:refund).once.with do |amount, reference, response|
          amount == 4000
        end.returns(Refund.new(:success => true))
        @payment.refund!
      end

      should 'trigger refund method with proper amount when host cancels ' do
        @payment.payable.update_column(:state, 'cancelled_by_host')
        PaymentGateway::StripePaymentGateway.any_instance.expects(:refund).once.with do |amount, reference, response|
          amount == 11000
        end.returns(Refund.new(:success => true))
        @payment.refund!
      end

      should 'calculate proper subtotal amount cents after refund once refund has been issued' do
        @refund = FactoryGirl.create(:refund, payment: @payment, amount: 3000)
        assert_equal @payment.subtotal_amount_cents - 3000, @payment.subtotal_amount_cents_after_refund
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
      @payment.refund!
    end
  end

  context 'foreign keys' do
    setup do
      @reservation = FactoryGirl.create(:reservation)
      @reservation.payment.destroy
      @payment = @reservation.build_payment({payment_method: FactoryGirl.build(:credit_card_payment_method)})
      @payment.save!
    end

    should 'assign correct key immediately' do
      assert @payment.company_id.present?
      assert_equal @payment.company_id, @payment.payable.company_id
    end

    context 'update company' do
      should 'assign correct company_id' do
        @payment.payable.location.update_attribute(:company_id, @payment.payable.location.company_id + 1)
        assert_equal @payment.payable.location.company_id, @payment.reload.company_id
      end

      should 'assign correct instance_id' do
        instance = FactoryGirl.create(:instance)
        @payment.payable.company.update_attribute(:instance_id, instance.id)
        PlatformContext.any_instance.stubs(:instance).returns(instance)
        assert_equal instance.id, @payment.reload.instance_id
      end

      should 'assign correct partner_id' do
        partner = FactoryGirl.create(:partner)
        @payment.company.update_attribute(:partner_id, partner.id)
        assert_equal partner.id, @payment.reload.partner_id
      end

    end
  end
end
