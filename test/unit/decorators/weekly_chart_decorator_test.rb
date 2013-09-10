require 'test_helper'

class WeeklyChartDecoratorTest < ActionView::TestCase

  setup do
    Timecop.travel(Time.zone.parse('2013-01-01'))
  end

  context 'a blank PaymentTransfer collection decorated with WeeklyChartDecorator' do

    setup do
      @weekly_chart = WeeklyChartDecorator.decorate(PaymentTransfer.all)
    end

    should 'return empty array for each day and each currency' do
      assert @weekly_chart.values.blank?
    end

    should 'return empty array of sums for each currency' do
      assert @weekly_chart.sums_by_currency.blank?
    end

    should 'display dates in label' do
      expected_dates = ['Dec 26', 'Dec 27', 'Dec 28', 'Dec 29', 'Dec 30', 'Dec 31', 'Jan 01']
      assert_equal expected_dates, @weekly_chart.labels
    end

  end

  context 'a filled ReservationCharge collection decorated with WeeklyChartDecorator' do

    setup do
      @last_week_reservation_charges = build_reservation_charges
      @weekly_chart = WeeklyChartDecorator.decorate(@last_week_reservation_charges)
    end

    should 'return array of sums for each day and each currency' do
      expected_daily_sums = [[11.0, 11.0, 11.0, 11.0, 11.0, 11.0, 64.0],
                             [11.0, 11.0, 11.0, 11.0, 11.0, 11.0, 99.0]]
      assert_equal expected_daily_sums, @weekly_chart.values
    end

    should 'return array of sums for each currency' do
      expected_sums_by_currency = {'USD' => Money.new(13000, 'USD'), 'CAD' => Money.new(16500, 'CAD')}
      assert_equal expected_sums_by_currency, @weekly_chart.sums_by_currency
    end

  end

  teardown do
    Timecop.return
  end

  private
  def build_reservation_charge(reservation, days_ago, subtotal, service_fee)
    FactoryGirl.build(:reservation_charge,
                      created_at: days_ago.days.ago,
                      reservation: reservation,
                      subtotal_amount_cents: subtotal,
                      service_fee_amount_cents: service_fee,
                      paid_at: days_ago.days.ago,
                      currency: reservation.currency)
  end

  def build_reservation_charges
    reservation_usd = FactoryGirl.build(:reservation, currency: 'USD')
    reservation_cad = FactoryGirl.build(:reservation, currency: 'CAD')

    # create a reservation charge for every of last six days
    reservation_charges = []
    [reservation_usd, reservation_cad].each do |reservation|
      6.downto(0).each do |i|
        reservation_charges << build_reservation_charge(reservation, i, 1000, 100)
      end
    end
    # create a yesterdays reservation charge with different amount
    reservation_charges << build_reservation_charge(reservation_usd, 0, 5000, 300)
    reservation_charges << build_reservation_charge(reservation_cad, 0, 8000, 800)

    reservation_charges
  end

end
