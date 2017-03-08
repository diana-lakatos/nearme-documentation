# frozen_string_literal: true
require 'test_helper'
require 'helpers/reservation_test_support'

class PaymentTransferTest < ActiveSupport::TestCase
  include ReservationTestSupport

  setup do
    @company = prepare_company_with_charged_reservations(reservation_count: 2)

    @reservation_1 = @company.reservations[0]
    @reservation_2 = @company.reservations[1]

    @payments = [
      @reservation_1.payment,
      @reservation_2.payment
    ]
  end

  context 'creating' do
    setup do
      @payment_transfer = @company.payment_transfers.build
    end

    should 'find with encrypted token' do
      @payment_gateway = PaymentGateway.last
      @payment_transfer.token = 'tokenowski'
      @payment_transfer.payment_gateway = @payment_gateway
      @payment_transfer.save!

      assert_equal 1, @payment_gateway.payment_transfers.with_token('tokenowski').count
    end

    should 'only allow charges of the same currency' do
      @reservations = prepare_charged_reservations_for_transactable(@reservation_1.transactable)
      reservation = @reservations.last
      reservation.payment.destroy

      rc = Payment.create!(
        payment_method: PaymentMethod.where(payment_method_type: 'credit_card').last,
        credit_card: FactoryGirl.build(:credit_card),
        payable: reservation,
        subtotal_amount: 10,
        service_fee_amount_guest: 1,
        service_fee_amount_host: 2,
        currency: 'NZD',
        payer: reservation.owner
      )

      @payment_transfer.payments = [@payments, rc].flatten
      assert !@payment_transfer.save
      assert @payment_transfer.errors[:currency].present?
    end

    should 'assign instance id' do
      @payment_transfer.payments = @payments
      @payment_transfer.save!
      @payment_transfer.reload
      assert_equal @payment_transfer.company.instance_id, @payment_transfer.instance_id
    end

    should 'calculate total_service_fee_cents' do
      @reservations = prepare_charged_reservations_for_transactable(@reservation_1.transactable)
      reservation = @reservations.last
      reservation.payment.destroy

      rc = Payment.create!(
        payment_method: PaymentMethod.where(payment_method_type: 'credit_card').last,
        credit_card: FactoryGirl.build(:credit_card),
        payable: reservation,
        subtotal_amount: 10,
        service_fee_amount_guest: 1,
        service_fee_amount_host: 2,
        currency: 'USD',
        payer: reservation.owner
      )

      @payment_transfer.payments = [@payments, rc].flatten
      assert @payment_transfer.save
      assert_equal Money.new(300, 'NZD'), @payment_transfer.total_service_fee
    end

    should 'assign currency attribute' do
      @payment_transfer.payments = @payments
      @payment_transfer.save!
      @payment_transfer.reload

      assert_equal @payments.first.currency, @payment_transfer.currency
    end

    should 'calculate amounts' do
      @payment_transfer.payments = @payments
      @payment_transfer.save!

      assert_equal @payments.map(&:subtotal_amount).sum - @payments.map(&:service_fee_amount_host).sum,
                   @payment_transfer.amount

      assert_equal @payments.map(&:service_fee_amount_guest).sum, @payment_transfer.service_fee_amount_guest
      assert_equal @payments.map(&:service_fee_amount_host).sum, @payment_transfer.service_fee_amount_host
    end
  end

  context 'correct amounts with advanced cancellation/refund policy' do
    setup do
      @company = FactoryGirl.build(:company)
      @payments = []
      @payments << @payment_1 = FactoryGirl.create(:paid_payment, company: @company,
                                                                  total_amount_cents: 1150,
                                                                  subtotal_amount_cents: 1000,
                                                                  service_fee_amount_guest_cents: 150,
                                                                  service_fee_amount_host_cents: 100)
      @payments << @payment_2 = FactoryGirl.create(:paid_payment, company: @company,
                                                                  total_amount_cents: 1200,
                                                                  subtotal_amount_cents: 1000,
                                                                  service_fee_amount_guest_cents: 200,
                                                                  service_fee_amount_host_cents: 150)

      @payment_transfer = @company.payment_transfers.build
    end

    should 'calculate correctly the total sum for transfers without refunds' do
      @payment_transfer.payments = @payments
      @payment_transfer.save!

      assert_equal 1000 + 1000 - 100 - 150, @payment_transfer.amount_cents # 1750
      assert_equal 150 + 200, @payment_transfer.service_fee_amount_guest_cents
      assert_equal 100 + 150, @payment_transfer.service_fee_amount_host_cents
    end

    should 'calculate correctly the total sum for transfers with refunds' do
      @order_1 = @payment_1.payable
      @order_2 = @payment_2.payable

      @order_1.transactable_line_item.update_attributes(unit_price_cents: @payment_1.subtotal_amount_cents, service_fee_guest_percent: 15, service_fee_host_percent: 10 )
      @order_2.transactable_line_item.update_attributes(unit_price_cents: @payment_2.subtotal_amount_cents, service_fee_guest_percent: 20, service_fee_host_percent: 15 )

      @order_1.reload
      @order_2.reload

      @order_1.transactable_line_item.build_service_fee
      @order_2.transactable_line_item.build_service_fee

      @order_1.transactable_line_item.build_host_fee
      @order_2.transactable_line_item.build_host_fee

      FactoryGirl.create(:cancelled_by_guest_refund_cellation_policy, cancellable: @order_1, amount_rule: "{{ order.subtotal_amount_money.cents | times: 0.6 }}" )
      FactoryGirl.create(:cancelled_by_host_refund_cellation_policy, cancellable: @order_2, amount_rule: "{{ order.total_amount_money.cents | times: 1 }}" )

      @payment_1.payable.user_cancel!
      @payment_2.payable.host_cancel!

      # Payment_1 was for $11,50, $1,5 guest fee, $1 host fee
      # when cancelled by guest we should refund 60% of subtotal amount 10$ = 6$
      # Fees are not refunded
      assert_equal 600, @order_1.refund_amount_cents

      # Payment_2 was for $12, $2 guest fee, $1,5 host fee
      # when cancelled by host we should refund $10 and host_service_fee $2
      assert_equal 1000 + 200, @order_2.refund_amount_cents

      @payment_transfer.payments = @payments
      @payment_transfer.save!

      # What we should transfer from cancelled reservation is:
      # Payment one is 4$ is returned to guest, 1$ is host fee and $5 we should transfer
      assert_equal 400 + 0, @payment_transfer.amount_cents
      assert_equal 150 + 0, @payment_transfer.service_fee_amount_guest_cents
      assert_equal 0 + 0, @payment_transfer.service_fee_amount_host_cents
    end
  end

  context '#gross_amount_cents' do
    should 'be the sum of the charge subtotals and the service fees' do
      pt = PaymentTransfer.new
      pt.amount_cents = 50_00
      pt.payment_gateway_fee_cents = 10_00
      pt.service_fee_amount_host_cents = 15_00
      assert_equal 75_00, pt.gross_amount_cents
    end
  end

  context '.pending' do
    should "include all PaymentTransfers that haven't been transferred" do
      pt1 = @company.payment_transfers.create!
      pt2 = @company.payment_transfers.create!
      pt3 = @company.payment_transfers.create!(transferred_at: Time.now)

      assert @company.payment_transfers.pending.include?(pt1)
      assert @company.payment_transfers.pending.include?(pt2)
      assert !@company.payment_transfers.pending.include?(pt3)
    end
  end

  context 'payout' do
    setup do
      @payment_transfer = @company.payment_transfers.build(currency: 'USD')
      @payment_transfer.payments = @payments
      @payout_gateway = FactoryGirl.create(:paypal_adaptive_payment_gateway)
      @merchant_account = MerchantAccount::PaypalAdaptiveMerchantAccount.create(
        payment_gateway: @payout_gateway,
        merchantable: @payment_transfer.company,
        state: 'verified',
        email: 'tomek@near-me.com'
      )
    end

    should 'be not paid if attempt to payout failed' do
      stub_active_merchant_interaction(success?: false)
      @payment_transfer.save!
      refute @payment_transfer.transferred?
    end

    should 'be paid if attempt to payout succeeded' do
      stub_active_merchant_interaction(success?: true)
      @payment_transfer.save!
      assert @payment_transfer.transferred?
    end
  end

  context 'possible_automated_payout_not_supported?' do
    setup do
      @payment_transfer = @company.payment_transfers.build(currency: 'USD')
      @payment_transfer.payments = @payments
      @paypal_gateway = FactoryGirl.create(:paypal_adaptive_payment_gateway)
    end

    should 'return true if possible processor exists but company has not provided settings' do
      FactoryGirl.create(:paypal_adaptive_merchant_account, payment_gateway: @paypal_gateway, merchantable: FactoryGirl.create(:company))
      assert @payment_transfer.possible_automated_payout_not_supported?
    end

    should 'return false if there is no potential processor and company has not provided settings' do
      PaymentGateway.destroy_all
      refute @payment_transfer.possible_automated_payout_not_supported?
    end

    should 'return false if there is no possible processor and company has provided settings' do
      FactoryGirl.create(:paypal_adaptive_merchant_account, payment_gateway: @paypal_gateway, merchantable: @company)
      refute @payment_transfer.possible_automated_payout_not_supported?
    end

    should 'return false if possible processor exists and company has provided settings' do
      FactoryGirl.create(:paypal_adaptive_merchant_account, payment_gateway: @paypal_gateway, merchantable: @company)
      refute @payment_transfer.possible_automated_payout_not_supported?
    end
  end

  context 'foreign keys' do
    setup do
      @company = FactoryGirl.create(:company)
      @payment_transfer = FactoryGirl.create(:payment_transfer, company: @company)
    end

    should 'assign correct key immediately' do
      @payment_transfer = FactoryGirl.create(:payment_transfer)
      assert @payment_transfer.instance_id.present?
    end

    should 'assign correct instance_id' do
      assert_equal @company.instance_id, @payment_transfer.instance_id
    end

    context 'update company' do
      should 'assign correct instance_id' do
        instance = FactoryGirl.create(:instance)
        @company.update_attribute(:instance_id, instance.id)
        PlatformContext.any_instance.stubs(:instance).returns(instance)
        assert_equal instance.id, @company.reload.instance_id
      end
    end
  end
end
