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

  context '#selected_dates_summary' do

    setup do
      @reservation = FactoryGirl.build(:reservation)
      @reservation.periods = []
      @reservation.add_period(Date.parse('2013-05-01'))
      @reservation.add_period(Date.parse('2013-05-02'))
      @reservation.add_period(Date.parse('2013-05-03'))
      @reservation.add_period(Date.parse('2013-05-06'))
      @reservation.add_period(Date.parse('2013-05-07'))
      @reservation.add_period(Date.parse('2013-05-09'))
      @reservation.save!
    end

    should 'group selected periods into ranges' do
      assert_equal "Wednesday, May  1&ndash;Friday, May  3<br />Monday, May  6&ndash;Tuesday, May  7<br />Thursday, May  9", selected_dates_summary(@reservation)
    end

  end
end
