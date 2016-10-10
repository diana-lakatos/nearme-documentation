require 'test_helper'

class UpdateInfoJobTest < ActiveSupport::TestCase
  should 'trigger InfoUpdater for given user and auth' do
    Rails.application.config.expects(:perform_social_jobs).returns(true)
    authentication = stub(id: 1, user: mock)
    updater = mock(:update)

    Authentication
      .expects(:find)
      .with(authentication.id)
      .returns(authentication)

    Authentication::InfoUpdater.expects(:new).with(authentication).returns(updater)

    UpdateInfoJob.perform(authentication.id)
  end
end
