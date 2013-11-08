# encoding: UTF-8
# above comment is required to display euro symbol correctly!
require 'test_helper'

class ReservationsHelperTest < ActionView::TestCase
  include ReservationsHelper
  include MoneyRails::ActionViewExtension

  def setup
    stub_mixpanel
    @unpaid_reservation = FactoryGirl.create(:reservation_with_credit_card)
    @unpaid_reservation.subtotal_amount_cents = 100_00
    @unpaid_reservation.service_fee_amount_cents = 10_00
    @unpaid_reservation.save!

    @paid_reservation = FactoryGirl.create(:reservation_with_credit_card)
    @paid_reservation.subtotal_amount_cents = 100_00
    @paid_reservation.service_fee_amount_cents = 10_00
    @paid_reservation.save!

    User::BillingGateway.any_instance.expects(:charge)
    @paid_reservation.confirm
  end

  context '#hourly_summary_for_period_without_date' do
    setup do
      @date = Date.parse('9.1.1990')
    end

    should 'use suffix in start time when it is different for start and end time' do
      period = stub(:date => Date.parse('9.1.1990'), :start_minute => 660, :end_minute => 780, :hours => 2)
      assert_equal '11:00am&ndash;1:00pm<br />(2.00 hours)', hourly_summary_for_period_without_date(period)
    end

    should 'not use suffix in start time when it is same for start and end time' do
      period = stub(:date => Date.parse('9.1.1990'), :start_minute => 720, :end_minute => 780, :hours => 1)

      assert_equal '12:00&ndash;1:00pm<br />(1.00 hours)', hourly_summary_for_period_without_date(period)
    end
  end

  context '#reservation_paid' do
    should "equal the amount paid" do
      assert_equal '$110.00', reservation_paid(@paid_reservation)
    end

    should "equal 'Pending' if pending payment" do
      assert_equal 'Pending', reservation_paid(@unpaid_reservation)
    end
  end

  context '#reservation_balance' do
    should "equal the amount remaining to be paid" do
      assert_equal '$-110.00', reservation_balance(@unpaid_reservation)
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
      assert_equal "01 May&ndash;03 May<br />06 May&ndash;07 May<br />09 May", selected_dates_summary(@reservation)
    end

  end

  context '#service fee' do

    setup do
      @reservation = FactoryGirl.build(:reservation)
    end

    should 'be free if amount is 0' do
      stub_reservation_fees_to(0)
      assert_equal 'Free!', reservation_total_price(@reservation)
      assert_equal 'Free!', reservation_subtotal_price(@reservation)
      assert_equal 'Free!', reservation_service_fee(@reservation)
    end

    should 'be free if amount is nil' do
      stub_reservation_fees_to(nil)
      assert_equal 'Free!', reservation_total_price(@reservation)
      assert_equal 'Free!', reservation_subtotal_price(@reservation)
      assert_equal 'Free!', reservation_service_fee(@reservation)
    end

    should 'be displayed correctly with currency if greater than 0' do
      stub_reservation_fees_to(1050)
      assert_equal '€10.50', reservation_total_price(@reservation)
      assert_equal '€10.50', reservation_subtotal_price(@reservation)
      assert_equal '€10.50', reservation_service_fee(@reservation)
    end
  end

  private

  def stub_reservation_fees_to(price, currency = 'EUR')
    @reservation.stubs(:service_fee_amount).returns(Money.new(price, currency))
    @reservation.stubs(:subtotal_amount).returns(Money.new(price, currency))
    @reservation.stubs(:total_amount).returns(Money.new(price, currency))
    @reservation.stubs(:service_fee_amount_cents).returns(price)
    @reservation.stubs(:subtotal_amount_cents).returns(price)
    @reservation.stubs(:total_amount_cents).returns(price)
  end
end
