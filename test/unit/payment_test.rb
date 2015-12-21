require 'test_helper'

class PaymentTest < ActiveSupport::TestCase

  setup do
    @payment_gateway = FactoryGirl.create(:stripe_payment_gateway)
  end

  context 'capture' do
    setup do
      @reservation = FactoryGirl.create(:reservation_with_credit_card)
    end

    context 'mixpanel' do

      should 'track charge in mixpanel after successful creation' do
        @reservation.create_billing_authorization(token: "token", payment_gateway: @payment_gateway, payment_gateway_mode: "test")
        stub_active_merchant_interaction
        ReservationChargeTrackerJob.expects(:perform_later).with(@reservation.date.end_of_day, @reservation.id).once
        @reservation.payments.create!(
          subtotal_amount: 105.24,
          service_fee_amount_guest: 23.18
        )
      end
    end
  end

  context 'refund' do

    setup do
      @charge = FactoryGirl.create(:charge, :response => 'charge_response')
      @payment = @charge.payment
      @payment.payable.create_billing_authorization(token: "token", payment_gateway: @payment_gateway, payment_gateway_mode: "test")
    end

    should 'find the right charge if there were failing attempts' do
      @charge.update_attribute(:success, false)
      FactoryGirl.create(:charge, :payment => @payment, :response => { id: "id" })
      PaymentGateway::StripePaymentGateway.any_instance.expects(:refund).once.returns(Refund.new(:success => true))
      @payment.refund
      assert @payment.reload.refunded?
    end

    should 'not be refunded if failed' do
      PaymentGateway::StripePaymentGateway.any_instance.expects(:refund).with do |amount, reference, charge_response|
        amount = 0; charge_response = { id: nil }
      end.returns(Refund.new(:success => false))
      @payment.refund
      refute @payment.reload.refunded?
    end

    should 'return if successful charge was not returned' do
      PaymentGateway.any_instance.expects(:refund).never
      @charge.update_attribute(:success, false)
      @payment.refund
      refute @payment.reload.refunded?
    end

    should 'return if payment was already refunded' do
      PaymentGateway.any_instance.expects(:refund).never
      @payment.update_attribute(:refunded_at, Time.zone.now)
      @payment.refund
    end

    should 'return if payment was not paid' do
      PaymentGateway.any_instance.expects(:refund).never
      @payment.update_attribute(:paid_at, nil)
      @payment.refund
      refute @payment.reload.refunded?
    end

    should 'refund via billing gateway with correct arguments if all ok' do
      PaymentGateway::StripePaymentGateway.any_instance.expects(:refund).once.returns(Refund.new(:success => true))
      @payment.refund
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
        PaymentGateway::StripePaymentGateway.any_instance.expects(:refund).once.returns(Refund.new(:success => true))
        assert_equal 1000, @payment.subtotal_amount_cents

        assert_equal 400, @payment.amount_to_be_refunded
        Refund.create(:success => true, :amount => 400, :payment => @payment)

        @payment.refund
        assert @payment.reload.refunded?
        assert_equal 0, @payment.final_service_fee_amount_host_cents
        assert_equal 100, @payment.final_service_fee_amount_guest_cents
        assert_equal 600, @payment.subtotal_amount_cents_after_refund
      end

      should 'refund proper amount when host cancels' do
        @payment.payable.update_column(:state, 'cancelled_by_host')
        PaymentGateway::StripePaymentGateway.any_instance.expects(:refund).once.returns(Refund.new(:success => true))
        assert_equal 1000, @payment.subtotal_amount_cents

        assert_equal 1100, @payment.amount_to_be_refunded
        Refund.create(:success => true, :amount => 1100, :payment => @payment)

        @payment.refund
        assert @payment.reload.refunded?
        assert_equal 0, @payment.final_service_fee_amount_host_cents
        assert_equal 0, @payment.final_service_fee_amount_guest_cents
        assert_equal 0, @payment.subtotal_amount_cents_after_refund
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
        @payment.refund
      end

      should 'trigger refund method with proper amount when host cancels ' do
        @payment.payable.update_column(:state, 'cancelled_by_host')
        PaymentGateway::StripePaymentGateway.any_instance.expects(:refund).once.with do |amount, reference, response|
          amount == 11000
        end.returns(Refund.new(:success => true))
        @payment.refund
      end

      should 'calculate proper subtotal amount cents after refund once refund has been issued' do
        @refund = FactoryGirl.create(:refund, payment: @payment, amount: 3000)
        assert_equal @payment.subtotal_amount_cents - 3000, @payment.subtotal_amount_cents_after_refund
      end

    end
  end

  context 'charge on save' do

    setup do
      @payment = FactoryGirl.build(:payment_unpaid)
      @payment.payable.create_billing_authorization(token: "token", payment_gateway: @payment_gateway, payment_gateway_mode: "test")
    end

    should 'trigger capture on save' do
      @payment.expects(:capture)
      @payment.save!
    end

    should 'not charge again if already charged' do
      PaymentGateway.any_instance.expects(:charge).never
      @payment.stubs(:paid_at).returns(Time.zone.now)
      @payment.capture
    end

  end

  context 'foreign keys' do
    setup do
      @payment = FactoryGirl.create(:payment)
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
