require 'test_helper'

class RecurringMailerRequestPhotosJobTest < ActiveSupport::TestCase
  setup do
    FactoryGirl.create(:listing, 
                       :last_request_photos_sent_at => 28.days.ago,
                       :photos_count => 0,
                       :activated_at => 28.days.ago)
  end

  should 'not be sent to user who unsubscribed previously' do
    listing = Listing.last
    user = listing.administrator
    user.unsubscribe('recurring_mailer/request_photos')
    RecurringMailerRequestPhotosJob.perform
    assert_equal listing.last_request_photos_sent_at, listing.reload.last_request_photos_sent_at
  end

  context 'will touch last_request_photos timestamp' do
    should 'for invalid listing' do
      listing = Listing.last
      refute listing.valid?
      RecurringMailerRequestPhotosJob.perform
      refute_equal listing.last_request_photos_sent_at, listing.reload.last_request_photos_sent_at
    end
  end
end
