require 'test_helper'

class RatingReminderJobTest < ActiveSupport::TestCase

  setup do
    ActionMailer::Base.deliveries.clear
  end

  context "With yesterday ending reservation" do

    setup do
      FactoryGirl.create(:domain)
      @reservation = FactoryGirl.create(:past_reservation)
      @guest = @reservation.owner
      @host = @reservation.listing.location.creator
    end

    should 'send reminder to both guest and host' do
      stub_local_time_to_return_hour(Location.any_instance, 12)
      RatingReminderJob.new(Date.current.to_s).perform
      assert_equal 2, ActionMailer::Base.deliveries.size

      @host_email = ActionMailer::Base.deliveries.detect { |e| e.to == [@host.email] }
      assert_match(/\[DesksNearMe\] Rate your guest at Listing \d+/, @host_email.subject)

      @guest_email = ActionMailer::Base.deliveries.detect { |e| e.to == [@guest.email] }
      assert_match(/\[DesksNearMe\] Rate your host at Listing \d+/, @guest_email.subject)

    end

    should 'not send any reminders while its not noon in local time zone this hour' do
      stub_local_time_to_return_hour(Location.any_instance, 7)
      RatingReminderJob.new(Date.current.to_s).perform

      assert_equal 0, ActionMailer::Base.deliveries.size
    end
  end

  context "With a future reservation" do

    setup do
      @reservation = FactoryGirl.create(:reservation)
    end

    should 'not send any reminders while reservation didnt end yesterday' do
      RatingReminderJob.new(Date.current.to_s).perform

      assert_equal 0, ActionMailer::Base.deliveries.size
    end

  end

  context "With an already sent reservation" do

    setup do
      @reservation = FactoryGirl.create(:past_reservation,
                                        request_guest_rating_email_sent_at: Time.zone.now,
                                        request_host_rating_email_sent_at: Time.zone.now)
    end

    should 'not send any reminders while reservation was already notified' do
      stub_local_time_to_return_hour(Location.any_instance, 12)
      RatingReminderJob.new(Date.current.to_s).perform

      assert_equal 0, ActionMailer::Base.deliveries.size
    end

  end

end
