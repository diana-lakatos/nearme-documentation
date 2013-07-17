require 'test_helper'

class PaymentTransferTest < ActiveSupport::TestCase
  def setup
    @company = FactoryGirl.create(:company)
    @location = FactoryGirl.create(:location, :company => @company)
    @listing_1 = FactoryGirl.create(:listing, :location => @location, :daily_price => 50)
    @listing_2 = FactoryGirl.create(:listing, :location => @location, :daily_price => 100)
    @reservation_1 = FactoryGirl.create(:reservation_with_credit_card,
      :listing => @listing_1
    )
    @reservation_2 = FactoryGirl.create(:reservation_with_credit_card,
      :listing => @listing_1
    )

    User::BillingGateway.any_instance.stubs(:charge).returns(true)

    @reservation_1.confirm
    @reservation_2.confirm

    @reservation_charges = [
      @reservation_1.reservation_charges.to_a,
      @reservation_2.reservation_charges.to_a
    ].flatten

    assert @reservation_charges.present?, @reservation_1.inspect
  end

  context "creating" do
    setup do
      @payment_transfer = @company.payment_transfers.build
    end

    should "only allow charges of the same currency" do
      rc = ReservationCharge.create!(
        :reservation => @reservation_1,
        :subtotal_amount => 10,
        :service_fee_amount => 1,
        :currency => 'NZD'
      )

      @payment_transfer.reservation_charges = [@reservation_charges, rc].flatten
      assert !@payment_transfer.save
      assert @payment_transfer.errors[:currency].present?
    end

    should "assign currency attribute" do
      @payment_transfer.reservation_charges = @reservation_charges
      @payment_transfer.save!

      assert_equal @reservation_charges.first.currency,
        @payment_transfer.currency
    end

    should "calculate amounts" do
      @payment_transfer.reservation_charges = @reservation_charges
      @payment_transfer.save!

      assert_equal @reservation_charges.map(&:subtotal_amount).sum,
        @payment_transfer.amount

      assert_equal @reservation_charges.map(&:service_fee_amount).sum,
        @payment_transfer.service_fee_amount
    end
  end

  context "#gross_amount_cents" do
    should "be the sum of the charge subtotals and the service fees" do
      pt = PaymentTransfer.new
      pt.amount_cents = 50_00
      pt.service_fee_amount_cents = 10_00
      assert_equal 60_00, pt.gross_amount_cents
    end
  end

  context ".pending_transfer" do
    should "include all PaymentTransfers that haven't been transferred" do
      pt1 = @company.payment_transfers.create!
      pt2 = @company.payment_transfers.create!
      pt3 = @company.payment_transfers.create!(:transferred_at => Time.now)

      assert @company.payment_transfers.pending_transfer.include?(pt1)
      assert @company.payment_transfers.pending_transfer.include?(pt2)
      assert !@company.payment_transfers.pending_transfer.include?(pt3)
    end
  end
end
