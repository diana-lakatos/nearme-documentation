require 'test_helper'

class DashboardHelperTest < ActionView::TestCase
  include DashboardHelper

  context '#time of expiry' do
    setup do
      Timecop.freeze
    end

    should "displays hours minutes and seconds left properly" do
      assert_equal '05:45', time_to_expiry(Time.now + 5.hours + 45.minutes + 12.seconds)
    end

    should "displays minutes and seconds without hours" do
      assert_equal '00:45', time_to_expiry(Time.now + 45.minutes + 12.seconds)
    end

    should "displays seconds without hours and minutes" do
      assert_equal 'less than minute', time_to_expiry(Time.now + 12.seconds)
    end

    teardown do
      Timecop.return
    end
  end

  context '#payments' do
    context 'group charges' do
      setup do
        setup_charges
      end

      should 'distinguish between currencies' do
        expected = {
          "USD" => {
            format_charge_date_for_graph(@yesterday) => Money.new(300, 'USD'),
            format_charge_date_for_graph(@three_days_ago) => Money.new(150, 'USD')
          },

          "CAD" => {
            format_charge_date_for_graph(@yesterday) => Money.new(700, 'CAD'),
            format_charge_date_for_graph(@three_days_ago) => Money.new(350, 'CAD')
          }
        }

        assert_equal expected, group_charges(ReservationCharge.all)
      end
    end

    context '#chart helper' do
      setup do
        setup_charges
      end

      should 'populate values array with 0 even if no charge has been made' do
        assert_equal [[0, 0, 0, 1.5, 0, 3, 0], [0, 0, 0, 3.5, 0, 7, 0]],
          values_for_chart(ReservationCharge.all)
      end

      should 'display values from today to 6 days ago in correct order' do
        Timecop.freeze(Date.parse('2013-07-14')) do
          assert_equal [
            format_charge_date_for_graph(Date.parse('2013-07-08')),
            format_charge_date_for_graph(Date.parse('2013-07-09')),
            format_charge_date_for_graph(Date.parse('2013-07-10')),
            format_charge_date_for_graph(Date.parse('2013-07-11')),
            format_charge_date_for_graph(Date.parse('2013-07-12')),
            format_charge_date_for_graph(Date.parse('2013-07-13')),
            format_charge_date_for_graph(Date.parse('2013-07-14')),
          ], labels_for_chart
        end
      end
    end

  end

  private

  def setup_charges
    @yesterday = Time.now.utc - 1.day
    @three_days_ago = Time.now.utc - 3.days
    @reservation_usd = FactoryGirl.create(:reservation, :currency => 'USD')
    @reservation_cad = FactoryGirl.create(:reservation, :currency => 'CAD')

    @charge_usd1 = FactoryGirl.create(:reservation_charge, :created_at => @yesterday,      :reservation => @reservation_usd, :subtotal_amount_cents => 90, :service_fee_amount_cents => 10)
    @charge_usd1 = FactoryGirl.create(:reservation_charge, :created_at => @three_days_ago, :reservation => @reservation_usd, :subtotal_amount_cents => 135, :service_fee_amount_cents => 15)
    @charge_usd2 = FactoryGirl.create(:reservation_charge, :created_at => @yesterday,      :reservation => @reservation_usd, :subtotal_amount_cents => 180, :service_fee_amount_cents => 20)
    @charge_cad1 = FactoryGirl.create(:reservation_charge, :created_at => @yesterday,      :reservation => @reservation_cad, :subtotal_amount_cents => 270, :service_fee_amount_cents => 30)
    @charge_cad1 = FactoryGirl.create(:reservation_charge, :created_at => @three_days_ago, :reservation => @reservation_cad, :subtotal_amount_cents => 315, :service_fee_amount_cents => 35)
    @charge_cad2 = FactoryGirl.create(:reservation_charge, :created_at => @yesterday,      :reservation => @reservation_cad, :subtotal_amount_cents => 360, :service_fee_amount_cents => 40)
  end

end
