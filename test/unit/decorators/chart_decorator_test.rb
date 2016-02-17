require 'test_helper'

class ChartDecoratorTest < ActionView::TestCase

  setup do
    travel_to(Time.zone.parse('2013-01-01'))
  end

  context 'a blank PaymentTransfer collection decorated with WeeklyChartDecorator' do

    setup do
      @chart = ChartDecorator.decorate(PaymentTransfer.all)
    end

    should 'return zeros for each day' do
      assert_equal [[0, 0, 0, 0, 0, 0, 0]], @chart.values
    end

    should 'return empty array of sums for each currency' do
      assert @chart.totals_by_currency.blank?
    end

    should 'display dates in label' do
      expected_dates = ["2014-12-26", "2014-12-27", "2014-12-28", "2014-12-29", "2014-12-30", "2014-12-31", "2015-01-01"].map do |date|
        I18n.l(Date.strptime(date), format: :day_and_month)
      end

      assert_equal expected_dates, @chart.labels
    end

  end

  context 'a filled ReservationCharge collection decorated with WeeklyChartDecorator' do

    setup do
      @last_week_payments = build_payments
      @chart = ChartDecorator.decorate(@last_week_payments)
    end

    should 'return array of sums for each day and each currency' do
      expected_daily_sums = [[22, 22, 22, 22, 22, 22, 163]]
      assert_equal expected_daily_sums, @chart.values
    end

    should 'return array of sums for each currency' do
      expected_totals_by_currency = {'USD' => Money.new(13000, 'USD'), 'CAD' => Money.new(16500, 'CAD')}
      assert_equal expected_totals_by_currency, @chart.totals_by_currency
    end

  end

  teardown do
    travel_back
  end

  private
  def build_payment(reservation, days_ago, subtotal, service_fee_guest)
    FactoryGirl.build(:payment,
                      created_at: days_ago.days.ago,
                      payable: reservation,
                      subtotal_amount_cents: subtotal,
                      service_fee_amount_guest_cents: service_fee_guest,
                      paid_at: days_ago.days.ago,
                      currency: reservation.currency)
  end

  def build_payments
    reservation_usd = FactoryGirl.build(:reservation, currency: 'USD')
    reservation_cad = FactoryGirl.build(:reservation, currency: 'CAD')

    # create a reservation charge for every of last six days
    payments = []
    [reservation_usd, reservation_cad].each do |reservation|
      6.downto(0).each do |i|
        payments << build_payment(reservation, i, 1000, 100)
      end
    end
    # create a yesterdays reservation charge with different amount
    payments << build_payment(reservation_usd, 0, 5000, 300)
    payments << build_payment(reservation_cad, 0, 8000, 800)

    payments
  end

end
