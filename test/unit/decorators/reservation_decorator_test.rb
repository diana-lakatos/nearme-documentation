require 'test_helper'

class ReservationDecoratorTest < ActionView::TestCase

  include MoneyRails::ActionViewExtension

  context 'A decorated reservation in a fixed date' do

    setup do
      @time = Time.new(2014, 1, 1).in_time_zone
      Timecop.travel(@time)
      @reservation = FactoryGirl.build(:reservation, date: @time.next_week.to_date).decorate
    end

    should 'return days_in_words' do
      assert_equal '1 Day', @reservation.days_in_words
    end

    should 'return selected_dates_summary' do
      assert_equal "<p>Monday, January 6</p>", @reservation.selected_dates_summary
    end

    should 'return short_dates' do
      assert_equal '6 Jan', @reservation.short_dates
    end

    should 'format_reservation_periods' do
      assert_equal '6 Jan', @reservation.format_reservation_periods
    end

    context 'with periods with duration tru two weeks' do

      setup do
        @reservation.add_period(Date.new(2014, 1, 13))
        @reservation.add_period(Date.new(2014, 1, 14))
      end

      should 'return selected_dates_summary' do
        expected = "<p>Monday, January 6</p><hr><p>Monday, January 13 &ndash; Tuesday, January 14</p>"
        assert_equal expected, @reservation.selected_dates_summary('<hr>')
      end

      should 'return short_dates' do
        assert_equal '6 Jan-14 Jan', @reservation.short_dates
      end

      should 'return right dates' do
        assert_equal '2014-01-06 (desk), 2014-01-13 (desk), and 2014-01-14 (desk)', @reservation.dates
      end
    end

    teardown do
      Timecop.return
    end
  end

  context 'A free reservation' do

    setup do
      stub_mixpanel
      @reservation = FactoryGirl.build(:reservation_with_credit_card,
                                       subtotal_amount: 0,
                                       service_fee_amount: 0).decorate
    end

    should 'return that its free' do
      assert_equal '$0.00', @reservation.paid
    end

    should 'return its subtotal_price' do
      assert_equal 'Free!', @reservation.subtotal_price
    end

    should 'return its service_fee' do
      assert_equal 'Free!', @reservation.service_fee
    end

    should 'return its total_price' do
      assert_equal 'Free!', @reservation.total_price
    end

    should 'return right manage_guests_action_column_class' do
      assert_equal 'split-2', @reservation.manage_guests_action_column_class
    end
  end

  context 'A priced reservation' do
    setup do
      stub_mixpanel
      @reservation = FactoryGirl.build(:reservation_with_credit_card,
                                       subtotal_amount_cents: 500_00,
                                       service_fee_amount_cents: 50_00).decorate
    end

    should 'return that its pending' do
      assert_equal 'Pending', @reservation.paid
    end

    context 'that was confirmed ( = paid)' do
      setup do
        User::BillingGateway.any_instance.expects(:charge)
        @reservation.save!
        @reservation.confirm
      end

      should "return right paid amount" do
        assert_equal '$55.00', @reservation.paid
      end

      should 'return its subtotal_price' do
        assert_equal '$50.00', @reservation.subtotal_price
      end

      should 'return its service_fee' do
        assert_equal '$5.00', @reservation.service_fee
      end

      should 'return its total_price' do
        assert_equal '$55.00', @reservation.total_price
      end

      should 'return right manage_guests_action_column_class' do
        assert_equal 'split-1', @reservation.manage_guests_action_column_class
      end
    end

  end

  context 'A hourly reservation' do
    setup do
      stub_mixpanel
      @time = Time.new(2014, 1, 1).in_time_zone
      Timecop.travel(@time)
      listing = FactoryGirl.create(:listing, hourly_reservations: true)
      @reservation = FactoryGirl.build(:reservation,
                                       subtotal_amount_cents: 500_00,
                                       service_fee_amount_cents: 50_00,
                                       listing: listing).decorate
    end

    should 'return hourly_summary_for_first_period with date and default hours' do
      assert_equal 'December 31 9:00am&ndash;5:00pm (8.00 hours)', @reservation.hourly_summary_for_first_period(true)
    end

    should 'return hourly_summary_for_first_period without date and with special hours' do
      period = @reservation.periods.first
      period.start_minute = 600 # 10am
      period.end_minute = 960 # 4pm
      assert_equal '10:00am&ndash;4:00pm<br />(6.00 hours)', @reservation.hourly_summary_for_first_period(false)
    end

    should 'format_reservation_periods' do
      assert_equal '31 Dec 9:00am&ndash;5:00pm', @reservation.format_reservation_periods
    end

    teardown do
      Timecop.return
    end
  end

end
