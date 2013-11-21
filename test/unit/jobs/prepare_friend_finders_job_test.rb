require 'test_helper'

class PrepareFriendFindersJobTest < ActiveSupport::TestCase
  context '#perform' do
    should 'trigger FindFriendJob on all valid auths' do
      auth = stub()
      job_mock = mock()
      Authentication.stubs(:with_valid_token).returns([auth])
      FindFriendsJob.expects(:new).with(auth).returns(job_mock)
      job_mock.expects(:perform)

      PrepareFriendFindersJob.perform
    end
  end
end
