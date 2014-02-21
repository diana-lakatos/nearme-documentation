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
      assert sms.body =~ Regexp.new("You have received a booking request on #{@reservation.instance.name}")
      assert sms.body =~ /Please confirm or decline from your dashboard:/
      assert sms.body =~ /http:\/\/goo.gl/
    end

    should "not render if host had disabled sms notifications" do
      @listing_owner.update_attribute(:sms_notifications_enabled, false)
      sms = ReservationSmsNotifier.notify_host_with_confirmation(@reservation)
      assert sms.is_a?(SmsNotifier::NullMessage)
      refute sms.deliver
    end

    should "not render if host had disabled sms notification for new reservation requests" do
      @listing_owner.update_attribute(:sms_preferences, { :new_reservation => '0' })
      sms = ReservationSmsNotifier.notify_host_with_confirmation(@reservation)
      assert sms.is_a?(SmsNotifier::NullMessage)
      refute sms.deliver
    end
  end

  context '#notify_guest_with_state_change' do
    should "render with the reservation" do
      @reservation_owner = @reservation.owner
      @reservation_owner.update_attribute(:mobile_number, "199999999")
      @reservation.confirm
      sms = ReservationSmsNotifier.notify_guest_with_state_change(@reservation)
      assert_equal @reservation_owner.full_mobile_number, sms.to
      assert sms.body =~ Regexp.new("Your booking for #{@reservation.listing.name} was confirmed. View booking:")
      assert sms.body =~ /http:\/\/goo.gl/
    end

    should "not render if user had disabled sms notification for reservation state changes" do
      @reservation.owner.sms_preferences = { :reservation_state_changed => '0' }
      sms = ReservationSmsNotifier.notify_guest_with_state_change(@reservation)
      assert sms.is_a?(SmsNotifier::NullMessage)
      refute sms.deliver
    end
  end
end

