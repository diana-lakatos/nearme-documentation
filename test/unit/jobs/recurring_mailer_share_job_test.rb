require 'test_helper'

class RecurringMailerShareJobTest < ActiveSupport::TestCase
  setup do
    FactoryGirl.create(:listing, 
                       :activated_at => 28.days.ago)
  end

  should 'not be sent to user who unsubscribed previously' do
    listing = Listing.last
    user = listing.administrator
    user.unsubscribe('recurring_mailer/share')
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
     RecurringMailerShareJob.perform
    end
  end
end
