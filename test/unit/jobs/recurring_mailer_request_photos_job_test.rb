require 'test_helper'

class RecurringMailerRequestPhotosJobTest < ActiveSupport::TestCase
  setup do
    @transactable = FactoryGirl.create(:transactable, :desksnearme, description: 'test',
                       :last_request_photos_sent_at => 28.days.ago,
                       enabled: true)
    @transactable.update_column(:activated_at, 28.days.ago)
  end

  should 'not be sent to user who unsubscribed previously' do
    @transactable.administrator.unsubscribe('recurring_mailer/request_photos')
    RecurringMailerRequestPhotosJob.perform
    assert_equal @transactable.last_request_photos_sent_at.to_i, @transactable.reload.last_request_photos_sent_at.to_i
  end

  context 'will touch last_request_photos timestamp' do
    should 'for invalid listing' do
      @transactable.description = nil
      @transactable.save(validate: false)
      refute @transactable.valid?
      RecurringMailerRequestPhotosJob.perform
      refute_equal @transactable.last_request_photos_sent_at, @transactable.reload.last_request_photos_sent_at
    end
  end
end
