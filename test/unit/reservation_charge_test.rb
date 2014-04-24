require 'test_helper'

class ReservationChargeTest < ActiveSupport::TestCase

  context 'capture' do
    setup do
      @reservation = FactoryGirl.create(:reservation_with_credit_card)
      @reservation.instance.instance_payment_gateways << FactoryGirl.create(:stripe_instance_payment_gateway)
      stub_mixpanel
    end

    context 'mixpanel' do
      setup do
        @expectation = ReservationChargeTrackerJob.expects(:perform_later).with(@reservation.date.end_of_day, @reservation.id)
      end

      should 'track charge in mixpanel after successful creation' do
        Billing::Gateway::Processor::Incoming::Stripe.any_instance.stubs(:charge)
        @expectation.once
        @reservation.reservation_charges.create!(
          subtotal_amount: 105.24,
          service_fee_amount_guest: 23.18
        )
      end

      should 'do not track charge in mixpanel if there is error processing credit card' do
        Billing::Gateway::Processor::Incoming::Stripe.any_instance.stubs(:charge).raises(Billing::CreditCardError)
        @expectation.never
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
  end

  context 'charge on save' do

    setup do
      @reservation_charge = FactoryGirl.build(:reservation_charge_unpaid)
      @reservation_charge.instance.instance_payment_gateways << FactoryGirl.create(:stripe_instance_payment_gateway)
    end

    should 'trigger capture on save' do
      @reservation_charge.expects(:capture)
      @reservation_charge.save!
    end

    should 'be paid if success' do
      @reservation_charge.stubs(:total_amount_cents).returns(12345)
      Billing::Gateway::Incoming.any_instance.expects(:charge).with({:amount_cents => 12345, :reference => @reservation_charge}).returns(true)
      @reservation_charge.save!
      assert @reservation_charge.reload.paid?
    end

    should 'be not paid if fail' do
      Billing::Gateway::Incoming.any_instance.expects(:charge).raises(Billing::CreditCardError.new('Error'))
      @reservation_charge.save!
      refute @reservation_charge.reload.paid?
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
      assert_equal @reservation_charge.company_id, @reservation_charge.reservation.company_id
    end

    context 'update company' do

      should 'assign correct company_id' do
        @reservation_charge.reservation.location.update_attribute(:company_id, @reservation_charge.reservation.location.company_id + 1)
        assert_equal @reservation_charge.reservation.location.company_id, @reservation_charge.reload.company_id
      end

      should 'assign correct instance_id' do
        instance = FactoryGirl.create(:instance)
        @reservation_charge.reservation.company.update_attribute(:instance_id, instance.id)
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
