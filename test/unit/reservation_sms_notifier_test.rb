require 'test_helper'
class ReservationSmsNotifierTest < ActiveSupport::TestCase
  setup do
    Googl.stubs(:shorten).returns(stub(:short_url => "http://goo.gl/abf324"))
    @listing = FactoryGirl.create(:listing)
    @listing_owner = @listing.creator
    @listing_owner.mobile_number = "124456789"
    @listing_owner.save!
    @reservation = FactoryGirl.create(:reservation, :listing => @listing)
  end

  context '#notify_host_with_confirmation' do
    should "render with the reservation" do
      sms = ReservationSmsNotifier.notify_host_with_confirmation(@reservation)
      assert_equal @listing_owner.full_mobile_number, sms.to
      assert sms.body =~ /You have received a booking request on Desks Near Me/
      assert sms.body =~ /Please confirm or decline from your dashboard:/
      assert sms.body =~ /http:\/\/goo.gl/
    end
  end
end

