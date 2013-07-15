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
        Timecop.freeze(Date.parse('2013-07-14'))
        assert_equal [
          format_charge_date_for_graph(Date.parse('2013-07-08')),
          format_charge_date_for_graph(Date.parse('2013-07-09')),
          format_charge_date_for_graph(Date.parse('2013-07-10')),
          format_charge_date_for_graph(Date.parse('2013-07-11')),
          format_charge_date_for_graph(Date.parse('2013-07-12')),
          format_charge_date_for_graph(Date.parse('2013-07-13')),
          format_charge_date_for_graph(Date.parse('2013-07-14')),
        ], labels_for_chart
        Timecop.return
      end
    end

  end

  private

  def setup_charges
    @yesterday = Time.now.utc - 1.day
    @three_days_ago = Time.now.utc - 3.days
    @charge_usd1 = FactoryGirl.create(:charge, :created_at => @yesterday, :currency => 'USD', :amount => 100)
    @charge_usd1 = FactoryGirl.create(:charge, :created_at => @three_days_ago, :currency => 'USD', :amount => 150)
    @charge_usd2 = FactoryGirl.create(:charge, :created_at => @yesterday, :currency => 'USD', :amount => 200)
    @charge_cad1 = FactoryGirl.create(:charge, :created_at => @yesterday, :currency => 'CAD', :amount => 300)
    @charge_cad1 = FactoryGirl.create(:charge, :created_at => @three_days_ago, :currency => 'CAD', :amount => 350)
    @charge_cad2 = FactoryGirl.create(:charge, :created_at => @yesterday, :currency => 'CAD', :amount => 400)
  end

end
