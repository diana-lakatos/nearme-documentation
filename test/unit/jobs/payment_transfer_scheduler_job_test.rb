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
          rc.mark_as_refuneded!
          assert rc.refunded?
          PaymentTransferSchedulerJob.perform
          assert @company_1.payment_transfers[0].payments.include?(rc)
        end

        should "not include manual payments" do
          FactoryGirl.create(:manual_payment_gateway)
          payment = FactoryGirl.create(:manual_payment, company: @company_1)
          assert payment.offline?
          PaymentTransferSchedulerJob.perform
          refute @company_1.payment_transfers[0].payments.include?(payment)
        end

        should 'calculate payment transfer amount correctly for refunded charges' do
          rc = @company_1.payments.first
          rc.update_attributes(
            cancellation_policy_penalty_percentage: 0.4,
            refunded_at: Time.zone.now
          )
          FactoryGirl.create(:refund, payment: rc, amount_cents: 3000)
          PaymentTransferSchedulerJob.perform
          assert_equal 6000, @company_1.payment_transfers.first.amount.cents
        end

        should "only include successfully paid reservation charges" do
          payment = @company_1.payments.first
          payment.update_column(:state, 'authorized')
          assert !payment.paid?

          PaymentTransferSchedulerJob.perform

          assert_equal (@company_1.payments - [payment]).sort, @company_1.payment_transfers[0].payments.sort
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
                                       :currency => 'NZD',
                                       :location => location
                                      )
          listing.action_type.day_pricings.first.update(price_cents: 5000)

          nzd_reservations = prepare_charged_reservations_for_listing(listing, 2)
          PaymentTransferSchedulerJob.perform

          assert_equal 2, @company_1.payment_transfers.count

          nzd_transfer = @company_1.payment_transfers.detect { |pt| pt.currency == 'NZD' }
          assert nzd_transfer, "Expected an NZD payment transfer"
          assert_equal nzd_reservations.map(&:payment).flatten.sort,
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
        @company.instance.update_columns(payment_transfers_frequency: "daily")
        @payment = FactoryGirl.create(:paid_product_payment, payable: @order, company: @company)
      end

      should "include order payments" do
        PaymentTransferSchedulerJob.perform
        assert_equal @order.payment, @company.payment_transfers[0].payments.last
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
        payment_transfer = @company.payment_transfers.first
        assert_equal 5000, payment_transfer.amount.cents
        assert_equal 'USD', payment_transfer.currency
        assert_equal @order.payment, payment_transfer.payments.last
      end

    end

  end
end
