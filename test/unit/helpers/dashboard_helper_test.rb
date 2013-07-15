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

      should 'distinguish between currencies' do
        setup_charges
        assert_equal ({
          "USD"=> { 
          format_charge_date_for_graph(@yesterday) => Money.new(300, 'USD'),
          format_charge_date_for_graph(@three_days_ago) => Money.new(150, 'USD')
        }, 
          "CAD"=> { 
          format_charge_date_for_graph(@yesterday) => Money.new(700, 'CAD'),
          format_charge_date_for_graph(@three_days_ago) => Money.new(350, 'CAD')
        }
        }), group_charges(Charge.all)
      end

    end

    context '#chart helper' do

      should 'populate values array with 0 even if no charge has been made' do
        setup_charges
        assert_equal [[0, 0, 0, 1.5, 0, 3, 0], [0, 0, 0, 3.5, 0, 7, 0]], values_for_chart(Charge.all)
      end

      should 'display values from today to 6 days ago in correct order' do
        assert_equal [
          format_charge_date_for_graph(Time.zone.today - 6.day),
          format_charge_date_for_graph(Time.zone.today - 5.day),
          format_charge_date_for_graph(Time.zone.today - 4.day),
          format_charge_date_for_graph(Time.zone.today - 3.day),
          format_charge_date_for_graph(Time.zone.today - 2.day),
          format_charge_date_for_graph(Time.zone.today - 1.day),
          format_charge_date_for_graph(Time.zone.today - 0.day)
        ], labels_for_chart
      end
    end

  end

  private

  def setup_charges
    @yesterday = "#{Time.zone.today - 1.day} 01:00:00"
    @three_days_ago = "#{Time.zone.today - 3.days} 01:00:00"
    @charge_usd1 = FactoryGirl.create(:charge, :created_at => @yesterday, :currency => 'USD', :amount => 100)
    @charge_usd1 = FactoryGirl.create(:charge, :created_at => @three_days_ago, :currency => 'USD', :amount => 150)
    @charge_usd2 = FactoryGirl.create(:charge, :created_at => @yesterday, :currency => 'USD', :amount => 200)
    @charge_cad1 = FactoryGirl.create(:charge, :created_at => @yesterday, :currency => 'CAD', :amount => 300)
    @charge_cad1 = FactoryGirl.create(:charge, :created_at => @three_days_ago, :currency => 'CAD', :amount => 350)
    @charge_cad2 = FactoryGirl.create(:charge, :created_at => @yesterday, :currency => 'CAD', :amount => 400)
  end

end
