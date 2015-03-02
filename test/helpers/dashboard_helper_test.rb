require "test_helper"

class DashboardHelperTest < ActionView::TestCase

  context "#booking_types_active_toggle" do
    setup do
      @transactable = FactoryGirl.create(:transactable)
    end

    should "return active if bookig type equals to transactables one" do
      assert_equal 'active', booking_types_active_toggle(@transactable, 'regular')
    end

    should "return active for content case if transactable booking type is overnight and booking_type is regular" do
      @transactable.booking_type = 'overnight'
      assert_equal 'active', booking_types_active_toggle(@transactable, 'regular', true)
    end

    should "return nil transactable booking is not equal to booking_type" do
      assert_equal nil, booking_types_active_toggle(@transactable, 'overnight')
    end
  end

end
