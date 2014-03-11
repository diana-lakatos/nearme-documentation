require 'test_helper'

class UpdateInfoJobTest < ActiveSupport::TestCase

  should 'trigger InfoUpdater for given user and auth' do
    Rails.application.config.expects(:perform_social_jobs).returns(true)
    authentication = stub(user: mock(), instance: Instance.default_instance)
    updater = mock(:update)
    Authentication::InfoUpdater.expects(:new).with(authentication).returns(updater)

    UpdateInfoJob.perform(authentication)
  end

end
