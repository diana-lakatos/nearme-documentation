require 'test_helper'

class DashboardHelperTest < ActionView::TestCase
  include DashboardHelper

  setup do
    Timecop.freeze
  end

  teardown do
    Timecop.return
  end

  context '#time of expiry' do
    should "displays hours minutes and seconds left properly" do
      assert_equal '05:45', time_to_expiry(Time.now + 5.hours + 45.minutes + 12.seconds)
    end

    should "displays minutes and seconds without hours" do
      assert_equal '00:45', time_to_expiry(Time.now + 45.minutes + 12.seconds)
    end

    should "displays seconds without hours and minutes" do
      assert_equal 'less than minute', time_to_expiry(Time.now + 12.seconds)
    end

  end

end
