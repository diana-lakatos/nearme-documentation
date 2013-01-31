require 'test_helper'

class ReservationsHelperTest < ActionView::TestCase
  include ReservationsHelper
  include MoneyRails::ActionViewExtension

  def setup
    @unpaid_reservation = FactoryGirl.create(:reservation_with_credit_card)
    @unpaid_reservation.total_amount_cents = 100_00
    @unpaid_reservation.save!

    @paid_reservation = FactoryGirl.create(:reservation_with_credit_card, payment_status: 'paid')
    @paid_reservation.total_amount_cents = 100_00
    @paid_reservation.save!
    FactoryGirl.create(:charge, :amount => @paid_reservation.total_amount_cents, :reference => @paid_reservation)
  end

  context '#reservation_paid' do
    should "equal the amount paid" do
      assert_equal '$100.00', reservation_paid(@paid_reservation)
    end

    should "equal 'Pending' if pending payment" do
      assert_equal 'Pending', reservation_paid(@unpaid_reservation)
    end
  end

  context '#reservation_balance' do
    should "equal the amount remaining to be paid" do
      assert_equal '$-100.00', reservation_balance(@unpaid_reservation)
      assert_equal '$0.00', reservation_balance(@paid_reservation)     
    end
  end
end