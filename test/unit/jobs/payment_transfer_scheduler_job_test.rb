require 'test_helper'
require 'helpers/reservation_test_support'

class PaymentTransferSchedulerJobTest < ActiveSupport::TestCase
  include ReservationTestSupport

  def setup
    stub_mixpanel
    @company_1 = prepare_company_with_charged_reservations(:reservation_count => 2)
    @company_2 = prepare_company_with_charged_reservations(:reservation_count => 3)
    PaymentTransfer.any_instance.stubs(:possible_automated_payout_not_supported?).returns(false).at_least(0)
    Billing::Gateway::Outcoming.any_instance.stubs(:payout).returns(stub(:success => true)).at_least(0)
  end

  context '#perform' do
    should "schedule payment transfers" do
      PaymentTransferSchedulerJob.perform

      assert_equal 1, @company_1.payment_transfers.count
      assert_equal 1, @company_2.payment_transfers.count

      assert_equal 9000, @company_1.payment_transfers.first.amount.cents
      assert_equal 'USD', @company_1.payment_transfers.first.currency
      assert_equal 13500, @company_2.payment_transfers.first.amount.cents
      assert_equal 'USD', @company_2.payment_transfers.first.currency

      assert_equal @company_1.reservation_charges.sort,
        @company_1.payment_transfers[0].reservation_charges.sort

      assert_equal @company_1.reservation_charges.sum(&:subtotal_amount_cents),
        @company_1.payment_transfers[0].reservation_charges.sum(&:subtotal_amount_cents)

      assert_equal @company_2.reservation_charges.sort,
        @company_2.payment_transfers[0].reservation_charges.sort

      assert_equal @company_2.reservation_charges.sum(&:subtotal_amount_cents),
        @company_2.payment_transfers[0].reservation_charges.sum(&:subtotal_amount_cents)
    end

    should "not include refunded reservation charges" do
      rc = @company_1.reservation_charges.first
      rc.touch(:refunded_at)
      assert rc.refunded?

      PaymentTransferSchedulerJob.perform

      assert_equal (@company_1.reservation_charges - [rc]).sort, @company_1.payment_transfers[0].reservation_charges.sort
    end

    should "only include successfully paid reservation charges" do
      rc = @company_1.reservation_charges.first
      rc.paid_at = nil
      rc.save!
      assert !rc.paid?

      PaymentTransferSchedulerJob.perform

      assert_equal (@company_1.reservation_charges - [rc]).sort, @company_1.payment_transfers[0].reservation_charges.sort
    end

    should "not touch already included reservation charges" do
      PaymentTransferSchedulerJob.perform

      assert_no_difference 'PaymentTransfer.count' do
        PaymentTransferSchedulerJob.perform
      end
    end

    should "generate separate transfers for separate currencies" do
      Billing::Gateway::Processor::Ingoing::Stripe.stubs(:currency_supported?).with('NZD').returns(true).at_least(1)
      location = FactoryGirl.create(:location,
        :company => @company_1,
        :currency => 'NZD'
      )

      listing = FactoryGirl.create(:listing,
        :daily_price => 50,
        :location => location
      )

      nzd_reservations = prepare_charged_reservations_for_listing(listing, 2)
      PaymentTransferSchedulerJob.perform

      assert_equal 2, @company_1.payment_transfers.count

      nzd_transfer = @company_1.payment_transfers.detect { |pt| pt.currency == 'NZD' }
      assert nzd_transfer, "Expected an NZD payment transfer"
      assert_equal nzd_reservations.map(&:reservation_charges).flatten.sort,
        nzd_transfer.reservation_charges.sort

    end

  end

end

