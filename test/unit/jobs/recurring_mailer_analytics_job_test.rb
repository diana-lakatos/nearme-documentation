require 'test_helper'

class RecurringMailerAnalyticsJobTest < ActiveSupport::TestCase
  setup do
    FactoryGirl.create(:listing, 
                       :activated_at => 28.days.ago)
    ActionMailer::Base.deliveries.clear
  end

  should 'not be sent to user who unsubscribed previously' do
    listing = Listing.last
    user = listing.administrator
    user.unsubscribe('recurring_mailer/analytics')
    RecurringMailerAnalyticsJob.perform
    assert_equal ActionMailer::Base.deliveries.size, 0
  end
end
