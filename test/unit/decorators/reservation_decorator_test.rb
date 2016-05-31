require 'test_helper'

class ReservationDecoratorTest < ActionView::TestCase

  include MoneyRails::ActionViewExtension

  context 'A decorated reservation in a fixed date' do

    setup do
      @time = DateTime.new(2014, 1, 1).in_time_zone
      travel_to(@time)
      @reservation = FactoryGirl.build(:reservation, date: @time.next_week.to_date).decorate
    end

    should 'return days_in_words' do
      assert_equal '1 Day', @reservation.days_in_words
    end

    should 'return selected_dates_summary' do
      assert_equal "<p>January 06, 2014</p>", @reservation.selected_dates_summary
    end

    should 'return short_dates' do
      assert_equal I18n.l(Date.new(2014, 1, 06), format: :day_and_month), @reservation.short_dates
    end

    should 'format_reservation_periods' do
      assert_equal I18n.l(Date.new(2014, 1, 06), format: :day_and_month), @reservation.format_reservation_periods
    end

    should 'displays hours minutes and seconds left properly' do
      assert_equal '5 hours, 45 minutes', @reservation.send(:time_to_expiry, Time.zone.now + 5.hours + 45.minutes + 12.seconds)
    end

    should 'displays minutes and seconds without hours' do
      assert_equal '45 minutes', @reservation.send(:time_to_expiry, (Time.zone.now + 45.minutes + 12.seconds))
    end

    should 'displays seconds without hours and minutes' do
      assert_equal 'less than minute', @reservation.send(:time_to_expiry, (Time.zone.now + 12.seconds))
    end

    context 'with periods with duration tru two weeks' do

      setup do
        @reservation.add_period(Date.new(2014, 1, 13))
        @reservation.add_period(Date.new(2014, 1, 14))
      end

      should 'return selected_dates_summary' do
        expected = "<p>January 06, 2014</p><hr /><p>January 13, 2014 &ndash; January 14, 2014</p>"
        assert_equal expected, @reservation.selected_dates_summary(separator: :hr)
      end

      should 'return short_dates' do
        assert_equal I18n.l(Date.new(2014, 1, 06), format: :day_and_month), @reservation.short_dates
      end

    end

    teardown do
      travel_back
    end
  end

  context 'A free reservation' do

    setup do
      ServiceType.first.update_columns(service_fee_guest_percent: 0)
      @payment = FactoryGirl.build(:manual_payment)
      @reservation = FactoryGirl.build(:unconfirmed_reservation, listing: create(:free_listing), payment: @payment).decorate
      @reservation.charge_and_confirm!
    end

    should 'return that its free' do
      assert_equal '$0.00', @reservation.paid
    end

    should 'return its subtotal_price' do
      assert_equal 'Free!', @reservation.subtotal_price
    end

    should 'return its service_fee' do
      assert_equal 'Free!', @reservation.service_fee_guest
    end

    should 'return its total_price' do
      assert_equal 'Free!', @reservation.total_price
    end

    should 'return right manage_guests_action_column_class' do
      assert_equal 'split-1', @reservation.manage_guests_action_column_class
    end
  end

  context 'A priced unconfirmed reservation' do
    setup do
      @reservation = FactoryGirl.build(:reservation,
                                       subtotal_amount_cents: 50_00,
                                       service_fee_amount_guest_cents: 5_00).decorate
    end

    should 'return that its Pending' do
      assert_equal 'Pending', @reservation.paid
    end
  end

  context 'that was confirmed ( = paid)' do
    setup do
      @payment = FactoryGirl.build(:paid_payment, subtotal_amount_cents: 50_00, service_fee_amount_guest_cents: 5_00)
      @reservation = FactoryGirl.build(:confirmed_reservation,
                                       subtotal_amount_cents: 50_00,
                                       service_fee_amount_guest_cents: 5_00, payment: @payment).decorate
    end

    should "return right paid amount" do
      assert_equal '$55.00', @reservation.paid
    end

    should 'return its subtotal_price' do
      assert_equal '$50.00', @reservation.subtotal_price
    end

    should 'return its service_fee' do
      assert_equal '$5.00', @reservation.service_fee_guest
    end

    should 'return its total_price' do
      assert_equal '$55.00', @reservation.total_price
    end

    should 'return right manage_guests_action_column_class' do
      assert_equal 'split-1', @reservation.manage_guests_action_column_class
    end
  end

  context 'A hourly reservation' do
    setup do
      @time = DateTime.new(2014, 1, 1).in_time_zone
      travel_to(@time)
      listing = FactoryGirl.create(:transactable, action_hourly_booking: true)
      @reservation = FactoryGirl.build(:reservation,
                                       subtotal_amount_cents: 500_00,
                                       service_fee_amount_guest_cents: 50_00,
                                       date: @time.to_date,
                                       listing: listing).decorate
    end

    should 'return hourly_summary_for_first_period with date and default hours' do
      assert_equal "01/01/2014 9:00&ndash;17:00 (8.00 hours)", @reservation.hourly_summary_for_first_period(true)
    end

    should 'return hourly_summary_for_first_period without date and with special hours' do
      period = @reservation.periods.first
      period.start_minute = 600 # 10am
      period.end_minute = 960 # 4pm
      assert_equal '10:00&ndash;16:00<br />(6.00 hours)', @reservation.hourly_summary_for_first_period(false)
    end

    should 'format_reservation_periods' do
      assert_equal "#{I18n.l(Date.new(2014, 1, 01), format: :day_and_month)} 9:00&ndash;17:00", @reservation.format_reservation_periods
    end

    teardown do
      travel_back
    end
  end

end
