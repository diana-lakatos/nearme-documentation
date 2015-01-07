require 'test_helper'

class PaymentTest < ActiveSupport::TestCase

  context 'capture' do
    setup do
      @reservation = FactoryGirl.create(:reservation_with_credit_card)
      @reservation.instance.instance_payment_gateways << FactoryGirl.create(:stripe_instance_payment_gateway)
      stub_mixpanel
    end

    context 'mixpanel' do

      should 'track charge in mixpanel after successful creation' do
        @reservation.create_billing_authorization(token: "token", payment_gateway_class: "Billing::Gateway::Processor::Incoming::Stripe", payment_gateway_mode: "test")
        Billing::Gateway::Processor::Incoming::Stripe.any_instance.stubs(:charge)
        ReservationChargeTrackerJob.expects(:perform_later).with(@reservation.date.end_of_day, @reservation.id).once
        @reservation.reservation_charges.create!(
          subtotal_amount: 105.24,
          service_fee_amount_guest: 23.18
        )
      end
    end
  end

  context 'refund' do

    setup do
      @charge = FactoryGirl.create(:charge, :response => 'charge_response')
      @reservation_charge = @charge.reference
      @reservation_charge.instance.instance_payment_gateways << FactoryGirl.create(:stripe_instance_payment_gateway)
      @reservation_charge.reference.create_billing_authorization(token: "token", payment_gateway_class: "Billing::Gateway::Processor::Incoming::Stripe", payment_gateway_mode: "test")
    end

    should 'find the right charge if there were failing attempts' do
      @charge.update_attribute(:success, false)
      FactoryGirl.create(:charge, :reference => @reservation_charge, :response => { id: "id" })
      Billing::Gateway::Processor::Incoming::Stripe.any_instance.expects(:refund).once.returns(Refund.new(:success => true))
      @reservation_charge.refund
      assert @reservation_charge.reload.refunded?
    end

    should 'not be refunded if failed' do
      Billing::Gateway::Processor::Incoming::Stripe.any_instance.expects(:refund).with do |amount, reference, charge_response|
        amount = 0; charge_response = { id: nil }
      end.returns(Refund.new(:success => false))
      @reservation_charge.refund
      refute @reservation_charge.reload.refunded?
    end

    should 'return if successful charge was not returned' do
      Billing::Gateway::Incoming.any_instance.expects(:refund).never
      @charge.update_attribute(:success, false)
      @reservation_charge.refund
      refute @reservation_charge.reload.refunded?
    end

    should 'return if reservation_charge was already refunded' do
      Billing::Gateway::Incoming.any_instance.expects(:refund).never
      @reservation_charge.update_attribute(:refunded_at, Time.zone.now)
      @reservation_charge.refund
    end

    should 'return if reservation_charge was not paid' do
      Billing::Gateway::Incoming.any_instance.expects(:refund).never
      @reservation_charge.update_attribute(:paid_at, nil)
      @reservation_charge.refund
      refute @reservation_charge.reload.refunded?
    end

    should 'refund via billing gateway with correct arguments if all ok' do
      Billing::Gateway::Processor::Incoming::Stripe.any_instance.expects(:refund).once.returns(Refund.new(:success => true))
      @reservation_charge.refund
    end

    context 'advanced cancellation policy penalty' do
      setup do
        @reservation_charge.update_attribute(:cancellation_policy_penalty_percentage, 60)
        @reservation_charge.update_attribute(:subtotal_amount_cents, 1000)
        @reservation_charge.update_attribute(:service_fee_amount_guest_cents, 100)
        @reservation_charge.update_attribute(:service_fee_amount_host_cents, 150)
      end

      should 'refund proper amount when guest cancels' do
        @reservation_charge.reservation.update_column(:state, 'cancelled_by_guest')
        Billing::Gateway::Processor::Incoming::Stripe.any_instance.expects(:refund).once.returns(Refund.new(:success => true))
        assert_equal 1000, @reservation_charge.subtotal_amount_cents

        assert_equal 400, @reservation_charge.amount_to_be_refunded
        Refund.create(:success => true, :amount => 400, :reference => @reservation_charge)

        @reservation_charge.refund
        assert @reservation_charge.reload.refunded?
        assert_equal 0, @reservation_charge.final_service_fee_amount_host_cents
        assert_equal 100, @reservation_charge.final_service_fee_amount_guest_cents
        assert_equal 600, @reservation_charge.subtotal_amount_cents_after_refund
      end

      should 'refund proper amount when host cancels' do
        @reservation_charge.reservation.update_column(:state, 'cancelled_by_host')
        Billing::Gateway::Processor::Incoming::Stripe.any_instance.expects(:refund).once.returns(Refund.new(:success => true))
        assert_equal 1000, @reservation_charge.subtotal_amount_cents

        assert_equal 1100, @reservation_charge.amount_to_be_refunded
        Refund.create(:success => true, :amount => 1100, :reference => @reservation_charge)

        @reservation_charge.refund
        assert @reservation_charge.reload.refunded?
        assert_equal 0, @reservation_charge.final_service_fee_amount_host_cents
        assert_equal 0, @reservation_charge.final_service_fee_amount_guest_cents
        assert_equal 0, @reservation_charge.subtotal_amount_cents_after_refund
      end
    end

    context 'cancelation policy penalty' do

      setup do
        @reservation_charge.update_attribute(:cancellation_policy_penalty_percentage, 60)
      end

      should 'return have subtotal amount after refund equal to subtotal amount if no refund has been made' do
        assert_equal 10000, @reservation_charge.subtotal_amount_cents_after_refund
      end

      should 'calculate proper number for amount_to_be_refunded if cancelled by guest' do
        @reservation_charge.reference.update_column(:state, 'cancelled_by_guest')
        assert_equal 10000, @reservation_charge.subtotal_amount_cents
        assert_equal 4000, @reservation_charge.amount_to_be_refunded
      end

      should 'calculate proper number for amount_to_be_refunded if cancelled by host' do
        @reservation_charge.reference.update_column(:state, 'cancelled_by_host')
        assert_equal 10000, @reservation_charge.subtotal_amount_cents
        assert_equal 11000, @reservation_charge.amount_to_be_refunded
      end

      should 'trigger refund method with proper amount when guest cancels ' do
        @reservation_charge.reference.update_column(:state, 'cancelled_by_guest')
        Billing::Gateway::Processor::Incoming::Stripe.any_instance.expects(:refund).once.with do |amount, reference, response|
          amount == 4000
        end.returns(Refund.new(:success => true))
        @reservation_charge.refund
      end

      should 'trigger refund method with proper amount when host cancels ' do
        @reservation_charge.reference.update_column(:state, 'cancelled_by_host')
        Billing::Gateway::Processor::Incoming::Stripe.any_instance.expects(:refund).once.with do |amount, reference, response|
          amount == 11000
        end.returns(Refund.new(:success => true))
        @reservation_charge.refund
      end

      should 'calculate proper subtotal amount cents after refund once refund has been issued' do
        @refund = FactoryGirl.create(:refund, reference: @reservation_charge, amount: 3000)
        assert_equal @reservation_charge.subtotal_amount_cents - 3000, @reservation_charge.subtotal_amount_cents_after_refund
      end

    end
  end

  context 'charge on save' do

    setup do
      @reservation_charge = FactoryGirl.build(:reservation_charge_unpaid)
      @reservation_charge.instance.instance_payment_gateways << FactoryGirl.create(:stripe_instance_payment_gateway)
      @reservation_charge.reference.create_billing_authorization(token: "token", payment_gateway_class: "Billing::Gateway::Processor::Incoming::Stripe", payment_gateway_mode: "test")
    end

    should 'trigger capture on save' do
      @reservation_charge.expects(:capture)
      @reservation_charge.save!
    end

    should 'not charge again if already charged' do
      Billing::Gateway::Incoming.any_instance.expects(:charge).never
      @reservation_charge.stubs(:paid_at).returns(Time.zone.now)
      @reservation_charge.capture
    end

  end

  context 'foreign keys' do
    setup do
      @reservation_charge = FactoryGirl.create(:reservation_charge)
    end

    should 'assign correct key immediately' do
      assert @reservation_charge.company_id.present?
      assert_equal @reservation_charge.company_id, @reservation_charge.reference.company_id
    end

    context 'update company' do

      should 'assign correct company_id' do
        @reservation_charge.reference.location.update_attribute(:company_id, @reservation_charge.reference.location.company_id + 1)
        assert_equal @reservation_charge.reference.location.company_id, @reservation_charge.reload.company_id
      end

      should 'assign correct instance_id' do
        instance = FactoryGirl.create(:instance)
        @reservation_charge.reference.company.update_attribute(:instance_id, instance.id)
        PlatformContext.any_instance.stubs(:instance).returns(instance)
        assert_equal instance.id, @reservation_charge.reload.instance_id
      end

      should 'assign correct partner_id' do
        partner = FactoryGirl.create(:partner)
        @reservation_charge.company.update_attribute(:partner_id, partner.id)
        assert_equal partner.id, @reservation_charge.reload.partner_id
      end

    end
  end
end
