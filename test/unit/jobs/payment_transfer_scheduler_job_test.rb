require 'test_helper'
require 'helpers/reservation_test_support'

class PaymentTransferSchedulerJobTest < ActiveSupport::TestCase
  include ReservationTestSupport

  setup do
    PaymentTransfer.any_instance.stubs(:possible_automated_payout_not_supported?).returns(false).at_least(0)
    PaymentGateway.any_instance.stubs(:payout).returns(stub(:success => true)).at_least(0)
  end

  context '#perform' do
    context 'for payments' do
      setup do
        @company_1 = prepare_company_with_charged_reservations(:reservation_count => 2)
        @company_2 = prepare_company_with_charged_reservations(:reservation_count => 3)
      end

      context "with daily payment transfers frequency" do
        setup do
          @company_1.instance.update_columns(payment_transfers_frequency: "daily")
          @company_2.instance.update_columns(payment_transfers_frequency: "daily")
        end

        should "schedule payment transfers " do
          PaymentTransferSchedulerJob.perform

          assert_equal 1, @company_1.payment_transfers.count
          assert_equal 1, @company_2.payment_transfers.count

          assert_equal 9000, @company_1.payment_transfers.first.amount.cents
          assert_equal 'USD', @company_1.payment_transfers.first.currency
          assert_equal 13500, @company_2.payment_transfers.first.amount.cents
          assert_equal 'USD', @company_2.payment_transfers.first.currency

          assert_equal @company_1.payments.sort,
            @company_1.payment_transfers[0].payments.sort

          assert_equal @company_1.payments.sum(:subtotal_amount_cents),
            @company_1.payment_transfers[0].payments.sum(:subtotal_amount_cents)

          assert_equal @company_2.payments.sort,
            @company_2.payment_transfers[0].payments.sort

          assert_equal @company_2.payments.sum(:subtotal_amount_cents),
            @company_2.payment_transfers[0].payments.sum(:subtotal_amount_cents)
        end

        should "include refunded reservation charges" do
          rc = @company_1.payments.first
          rc.touch(:refunded_at)
          assert rc.refunded?
          PaymentTransferSchedulerJob.perform
          assert @company_1.payment_transfers[0].payments.include?(rc)
        end

        should 'calculate payment transfer amount correctly for refunded charges' do
          rc = @company_1.payments.first
          rc.update_attributes(
            cancellation_policy_penalty_percentage: 0.4,
            refunded_at: Time.zone.now
          )
          FactoryGirl.create(:refund, payment: rc, amount: 3000)
          PaymentTransferSchedulerJob.perform
          assert_equal 6000, @company_1.payment_transfers.first.amount.cents
        end

        should "only include successfully paid reservation charges" do
          rc = @company_1.payments.first
          rc.paid_at = nil
          rc.save!
          assert !rc.paid?

          PaymentTransferSchedulerJob.perform

          assert_equal (@company_1.payments - [rc]).sort, @company_1.payment_transfers[0].payments.sort
        end

        should "not touch already included reservation charges" do
          PaymentTransferSchedulerJob.perform

          assert_no_difference 'PaymentTransfer.count' do
            PaymentTransferSchedulerJob.perform
          end
        end

        should "generate separate transfers for separate currencies" do
          location = FactoryGirl.create(:location,
                                        :company => @company_1
                                       )

          listing = FactoryGirl.create(:transactable,
                                       :daily_price => 50,
                                       :currency => 'NZD',
                                       :location => location
                                      )

          nzd_reservations = prepare_charged_reservations_for_listing(listing, 2)
          PaymentTransferSchedulerJob.perform

          assert_equal 2, @company_1.payment_transfers.count

          nzd_transfer = @company_1.payment_transfers.detect { |pt| pt.currency == 'NZD' }
          assert nzd_transfer, "Expected an NZD payment transfer"
          assert_equal nzd_reservations.map(&:payments).flatten.sort,
            nzd_transfer.payments.sort

        end
      end

      context "ensure that job properly used generate_payment_transfers_today? method" do
        setup do
          @company_1.instance.update_columns(payment_transfers_frequency: "fortnightly")
        end

        should "schedule payment transfers every 15th day of the month" do
          travel_to(Time.zone.now.next_month.beginning_of_month + 14.days) do
            PaymentTransferSchedulerJob.perform
          end
          assert_equal 1, @company_1.payment_transfers.count
        end

        should "not schedule payment transfers first Monday after 1st day of the month" do
          travel_to(Time.zone.now.next_month.beginning_of_month.next_week) do
            PaymentTransferSchedulerJob.perform
          end
          assert_equal 0, @company_1.payment_transfers.count
        end
      end

    end

    context 'for sold products' do

      setup do
        @order = FactoryGirl.create(:completed_order_with_totals)
        @company = @order.company
        @payment = FactoryGirl.create(:order_charge, payable: @order, currency: 'USD')
        @company.instance.update_columns(payment_transfers_frequency: "daily")
      end

      should "include order payments" do

        PaymentTransferSchedulerJob.perform

        assert_equal @order.near_me_payments.sort, @company.payment_transfers[0].payments.sort
      end

      should "not touch already included order line items" do
        PaymentTransferSchedulerJob.perform

        assert_no_difference 'PaymentTransfer.count' do
          PaymentTransferSchedulerJob.perform
        end
      end

      should "schedule payment transfers with daily payment transfers frequency" do
        PaymentTransferSchedulerJob.perform

        assert_equal 1, @company.payment_transfers.count
        assert_equal 5000, @company.payment_transfers.first.amount.cents
        assert_equal 'USD', @company.payment_transfers.first.currency
        assert_equal @order.near_me_payments.sort,
          @company.payment_transfers[0].payments.sort
      end

    end

  end
end
