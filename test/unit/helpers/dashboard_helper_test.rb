require 'test_helper'

class DashboardHelperTest < ActionView::TestCase
  include DashboardHelper

  context '#time of expiry' do
    setup do
      Timecop.freeze
    end

    should "displays hours minutes and seconds left properly" do
      assert_equal '5 hours, 45 minutes', time_to_expiry(Time.zone.now + 5.hours + 45.minutes + 12.seconds)
    end

    should "displays minutes and seconds without hours" do
      assert_equal '45 minutes', time_to_expiry(Time.zone.now + 45.minutes + 12.seconds)
    end

    should "displays seconds without hours and minutes" do
      assert_equal 'less than minute', time_to_expiry(Time.zone.now + 12.seconds)
    end

    teardown do
      Timecop.return
    end
  end

end
