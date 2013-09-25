require 'test_helper'
require 'helpers/reservation_test_support'

class PaymentTransferSchedulerJobTest < ActiveSupport::TestCase
  include ReservationTestSupport

  def setup
    @company_1 = prepare_company_with_charged_reservations(:reservation_count => 2)
    @company_2 = prepare_company_with_charged_reservations(:reservation_count => 2)
  end

  context '#perform' do
    should "schedule payment transfers" do
      PaymentTransferSchedulerJob.new.perform

      assert_equal 1, @company_1.payment_transfers.count
      assert_equal 1, @company_2.payment_transfers.count

      assert_equal @company_1.reservation_charges.sort,
        @company_1.payment_transfers[0].reservation_charges.sort

      assert_equal @company_2.reservation_charges.sort,
        @company_2.payment_transfers[0].reservation_charges.sort
    end

    should "only include successfully paid reservation charges" do
      rc = @company_1.reservation_charges.first
      rc.paid_at = nil
      rc.save!
      assert !rc.paid?

      PaymentTransferSchedulerJob.new.perform

      assert_equal @company_1.reservation_charges - [rc],
        @company_1.payment_transfers[0].reservation_charges
    end

    should "not touch already included reservation charges" do
      PaymentTransferSchedulerJob.new.perform

      assert_no_difference 'PaymentTransfer.count' do
        PaymentTransferSchedulerJob.new.perform
      end
    end

    should "generate separate transfers for separate currencies" do
      location = FactoryGirl.create(:location,
        :company => @company_1,
        :currency => 'NZD'
      )

      listing = FactoryGirl.create(:listing,
        :daily_price => 50,
        :location => location
      )

      nzd_reservations = prepare_charged_reservations_for_listing(listing, 2)
      PaymentTransferSchedulerJob.new.perform

      assert_equal 2, @company_1.payment_transfers.count

      nzd_transfer = @company_1.payment_transfers.detect { |pt| pt.currency == 'NZD' }
      assert nzd_transfer, "Expected an NZD payment transfer"
      assert_equal nzd_reservations.map(&:reservation_charges).flatten,
        nzd_transfer.reservation_charges
    end
  end

end

