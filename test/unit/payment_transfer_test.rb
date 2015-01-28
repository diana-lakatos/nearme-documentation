require 'test_helper'
require 'helpers/reservation_test_support'

class PaymentTransferTest < ActiveSupport::TestCase
  include ReservationTestSupport

  setup do
    stub_mixpanel
    @company = prepare_company_with_charged_reservations(:reservation_count => 2)

    @reservation_1 = @company.reservations[0]
    @reservation_2 = @company.reservations[1]

    @payments = [
      @reservation_1.payments.to_a,
      @reservation_2.payments.to_a
    ].flatten
    Billing::Gateway::Outgoing.any_instance.stubs(:payout).returns(stub(:success => true)).at_least(0)
  end

  context "creating" do
    setup do
      @payment_transfer = @company.payment_transfers.build
    end

    should "only allow charges of the same currency" do
      rc = Payment.create!(
        :payable => @reservation_1,
        :subtotal_amount => 10,
        :service_fee_amount_guest => 1,
        :service_fee_amount_host => 2,
        :currency => 'NZD'
      )

      @payment_transfer.payments = [@payments, rc].flatten
      assert !@payment_transfer.save
      assert @payment_transfer.errors[:currency].present?
    end

    should "assign instance id" do
      @payment_transfer.payments = @payments
      @payment_transfer.save!
      @payment_transfer.reload
      assert_equal @payment_transfer.company.instance_id, @payment_transfer.instance_id
    end

    should "assign currency attribute" do
      @payment_transfer.payments = @payments
      @payment_transfer.save!
      @payment_transfer.reload

      assert_equal @payments.first.currency, @payment_transfer.currency
    end

    should "calculate amounts" do
      @payment_transfer.payments = @payments
      @payment_transfer.save!

      assert_equal @payments.map(&:subtotal_amount).sum - @payments.map(&:service_fee_amount_host).sum,
        @payment_transfer.amount

      assert_equal @payments.map(&:service_fee_amount_guest).sum, @payment_transfer.service_fee_amount_guest
      assert_equal @payments.map(&:service_fee_amount_host).sum, @payment_transfer.service_fee_amount_host
    end
  end

  context "correct amounts with advanced cancellation/refund policy" do
    setup do
      listing = FactoryGirl.create(:transactable, { :daily_price => 10 })
      prepare_charged_reservations_for_listing(listing, 2, {
        :reservation_0 => {
          :service_fee_amount_guest_cents => 150,
          :service_fee_amount_host_cents => 100,
          :cancellation_policy_penalty_percentage => 60
        },
        :reservation_1 => {
          :service_fee_amount_guest_cents => 200,
          :service_fee_amount_host_cents => 150,
          :cancellation_policy_penalty_percentage => 50
        }
      })
      @refunds_company = listing.company

      @refunds_payment_transfer = @refunds_company.payment_transfers.build

      @refunds_reservation_1 = @refunds_company.reservations.order(:id).first
      @refunds_reservation_2 = @refunds_company.reservations.order(:id).second

      @refunds_payments = [
        @refunds_reservation_1.payments.to_a,
        @refunds_reservation_2.payments.to_a
      ].flatten
    end

    should "calculate correctly the total sum for transfers without refunds" do
      @refunds_payment_transfer.payments = @refunds_payments
      @refunds_payment_transfer.save!

      assert_equal 1000 + 1000 - 100 - 150, @refunds_payment_transfer.amount_cents
      assert_equal 150 + 200, @refunds_payment_transfer.service_fee_amount_guest_cents
      assert_equal 100 + 150, @refunds_payment_transfer.service_fee_amount_host_cents
    end

    should "calculate correctly the total sum for transfers with refunds" do
      #Billing::Gateway::Processor::Incoming::Stripe.any_instance.expects(:refund).returns(Refund.new(:success => true))

      @refunds_payments[0].payable.user_cancel!
      @refunds_payments[1].payable.host_cancel!
      @refunds_payments[0].refund
      @refunds_payments[1].refund

      assert_equal 400, @refunds_payments[0].amount_to_be_refunded
      assert_equal 1000 + 200, @refunds_payments[1].amount_to_be_refunded
      Refund.create(:success => true, :amount => 400, :payment => @refunds_payments[0])
      Refund.create(:success => true, :amount => 1000 + 200, :payment => @refunds_payments[1])

      @refunds_payment_transfer.payments = @refunds_payments
      @refunds_payment_transfer.save!

      assert_equal 600 + 0, @refunds_payment_transfer.amount_cents
      assert_equal 150 + 0, @refunds_payment_transfer.service_fee_amount_guest_cents
      assert_equal 0, @refunds_payment_transfer.service_fee_amount_host_cents
    end
  end

  context "#gross_amount_cents" do
    should "be the sum of the charge subtotals and the service fees" do
      pt = PaymentTransfer.new
      pt.amount_cents = 50_00
      pt.service_fee_amount_guest_cents = 10_00
      pt.service_fee_amount_host_cents = 15_00
      assert_equal 75_00, pt.gross_amount_cents
    end
  end

  context ".pending" do
    should "include all PaymentTransfers that haven't been transferred" do
      pt1 = @company.payment_transfers.create!
      pt2 = @company.payment_transfers.create!
      pt3 = @company.payment_transfers.create!(:transferred_at => Time.now)

      assert @company.payment_transfers.pending.include?(pt1)
      assert @company.payment_transfers.pending.include?(pt2)
      assert !@company.payment_transfers.pending.include?(pt3)
    end
  end


  context 'payout' do
    setup do
      Billing::Gateway::Processor::Outgoing::ProcessorFactory.stubs(:paypal_supported?).returns(true).once
      Billing::Gateway::Processor::Outgoing::ProcessorFactory.stubs(:receiver_supports_paypal?).returns(true).once
      @payment_transfer = @company.payment_transfers.build
      @payment_transfer.payments = @payments
    end

    should 'be not paid if attempt to payout failed' do
      Billing::Gateway::Outgoing.any_instance.expects(:payout).with { |hash| Money === hash[:amount] && @payment_transfer == hash[:reference] }.once.returns(stub(:success => false))
      @payment_transfer.save!
      refute @payment_transfer.transferred?
    end

    should 'be paid if attempt to payout succeeded' do
      Billing::Gateway::Outgoing.any_instance.expects(:payout).with { |hash| Money === hash[:amount] && @payment_transfer == hash[:reference] }.once.returns(stub(:success => true))
      @payment_transfer.save!
      assert @payment_transfer.transferred?
    end
  end

  context 'possible_automated_payout_not_supported?' do

    setup do
      @payment_transfer = @company.payment_transfers.build
      @payment_transfer.payments = @payments
    end

    should "return true if possible processor exists but company has not provided settings" do
      Billing::Gateway::Outgoing.any_instance.stubs(:possible?).returns(false)
      Billing::Gateway::Outgoing.any_instance.stubs(:support_automated_payout?).returns(true)
      assert @payment_transfer.possible_automated_payout_not_supported?
    end

    should "return false if there is no potential processor and company has not provided settings" do
      Billing::Gateway::Outgoing.any_instance.stubs(:possible?).returns(false)
      Billing::Gateway::Outgoing.any_instance.stubs(:support_automated_payout?).returns(false)
      refute @payment_transfer.possible_automated_payout_not_supported?
    end

    should "return false if there is no possible processor and company has provided settings" do
      Billing::Gateway::Outgoing.any_instance.stubs(:possible?).returns(true)
      Billing::Gateway::Outgoing.any_instance.stubs(:support_automated_payout?).returns(false)
      refute @payment_transfer.possible_automated_payout_not_supported?
    end

    should "return false if possible processor exists and company has provided settings" do
      Billing::Gateway::Outgoing.any_instance.stubs(:possible?).returns(true)
      Billing::Gateway::Outgoing.any_instance.stubs(:support_automated_payout?).returns(true)
      refute @payment_transfer.possible_automated_payout_not_supported?
    end

  end

  context 'foreign keys' do
    setup do
      @company = FactoryGirl.create(:company)
      @payment_transfer = FactoryGirl.create(:payment_transfer, :company => @company)
    end

    should 'assign correct key immediately' do
      @payment_transfer = FactoryGirl.create(:payment_transfer)
      assert @payment_transfer.instance_id.present?
    end

    should 'assign correct instance_id' do
      assert_equal @company.instance_id, @payment_transfer.instance_id
    end

    should 'assign correct partner_id' do
      @company = FactoryGirl.create(:company)
      @company.update_attribute(:partner_id, FactoryGirl.create(:partner).id)
      PlatformContext.current = PlatformContext.new(@company)
      @payment_transfer = FactoryGirl.create(:payment_transfer, :company => @company)
      assert_equal @company.partner_id, @payment_transfer.partner_id
      assert @payment_transfer.partner_id.present?
    end

    context 'update company' do

      should 'assign correct partner_id' do
        partner = FactoryGirl.create(:partner)
        @company.update_attribute(:partner_id, partner.id)
        assert_equal partner.id, @payment_transfer.reload.partner_id
      end

      should 'assign correct instance_id' do
        instance = FactoryGirl.create(:instance)
        @company.update_attribute(:instance_id, instance.id)
        PlatformContext.any_instance.stubs(:instance).returns(instance)
        assert_equal instance.id, @company.reload.instance_id
      end
    end
  end
end
