require 'test_helper'
require 'helpers/reservation_test_support'

class PaymentTransferSchedulerJobTest < ActiveSupport::TestCase
  include ReservationTestSupport

  def setup
    stub_mixpanel
    PaymentTransfer.any_instance.stubs(:possible_automated_payout_not_supported?).returns(false).at_least(0)
    Billing::Gateway::Outgoing.any_instance.stubs(:payout).returns(stub(:success => true)).at_least(0)
  end

  context '#perform' do
    context 'for reservation_charges' do
      setup do
        @company_1 = prepare_company_with_charged_reservations(:reservation_count => 2)
        @company_2 = prepare_company_with_charged_reservations(:reservation_count => 3)
      end

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
        location = FactoryGirl.create(:location,
          :company => @company_1,
          :currency => 'NZD'
        )

        listing = FactoryGirl.create(:transactable,
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

    context 'for sold products' do
      setup do
        @order = FactoryGirl.create(:completed_order_with_totals)
        @company = @order.company
      end

      should "schedule payment transfers" do
        PaymentTransferSchedulerJob.perform

        assert_equal 1, @company.payment_transfers.count
        assert_equal 5000, @company.payment_transfers.first.amount.cents
        assert_equal 'USD', @company.payment_transfers.first.currency
        assert_equal @company.order_line_items.sort,
          @company.payment_transfers[0].order_line_items.sort
      end

      should "only include line_items from completed orders (paid)" do
        not_completed_order = FactoryGirl.create(:order_with_line_items)

        PaymentTransferSchedulerJob.perform

        assert_equal @order.line_items.sort, @company.payment_transfers[0].order_line_items.sort
      end

      should "not touch already included order line items" do
        PaymentTransferSchedulerJob.perform

        assert_no_difference 'PaymentTransfer.count' do
          PaymentTransferSchedulerJob.perform
        end
      end
    end
  end
end

