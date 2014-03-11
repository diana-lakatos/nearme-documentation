require 'test_helper'

class PrepareFriendFindersJobTest < ActiveSupport::TestCase
  context '#perform' do
    should 'trigger FindFriendJob on all valid auths' do
      auth = stub(:instance => Instance.default_instance)
      Authentication.stubs(:with_valid_token).returns([auth])
      FindFriendsJob.expects(:perform).with(auth)
      PrepareFriendFindersJob.perform
    end
  end
end
