require 'test_helper'
class ReservationSmsNotifierTest < ActiveSupport::TestCase
  setup do
    @listing = FactoryGirl.create(:listing)
    @listing_owner = @listing.creator
    @listing_owner.mobile_number = "124456789"
    @listing_owner.save!
    @reservation = FactoryGirl.create(:reservation, :listing => @listing)
  end

  context '#notify_host_with_confirmation' do
    should "render with the reservation" do
      sms = ReservationSmsNotifier.notify_host_with_confirmation(@reservation)
      assert_equal @listing_owner.mobile_number, sms.to
      assert sms.body =~ /You have a reservation on Desks Near Me/, "Body was unexpectedly: #{sms.body}"
    end
  end
end

