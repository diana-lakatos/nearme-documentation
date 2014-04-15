require 'test_helper'

class RecurringMailerRequestPhotosJobTest < ActiveSupport::TestCase
  setup do
    @transactable = FactoryGirl.create(:transactable,
                       :last_request_photos_sent_at => 28.days.ago,
                       :photos_count_to_be_created => 0, enabled: true)
    @transactable.update_column(:activated_at, 28.days.ago)
  end

  should 'not be sent to user who unsubscribed previously' do
    @transactable.administrator.unsubscribe('recurring_mailer/request_photos')
    RecurringMailerRequestPhotosJob.perform
    assert_equal @transactable.last_request_photos_sent_at, @transactable.reload.last_request_photos_sent_at
  end

  context 'will touch last_request_photos timestamp' do
    should 'for invalid listing' do
      stub_mixpanel
      @transactable.update_column(:description, nil)
      refute @transactable.valid?
      RecurringMailerRequestPhotosJob.perform
      refute_equal @transactable.last_request_photos_sent_at, @transactable.reload.last_request_photos_sent_at
    end
  end
end
