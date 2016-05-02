require 'test_helper'

class PrepareFriendFindersJobTest < ActiveSupport::TestCase
  context '#perform' do
    should 'trigger FindFriendJob on all valid auths' do
      authentication = stub(id: 1)
      Authentication.stubs(:with_valid_token).returns([authentication])
      FindFriendsJob.expects(:perform).with(authentication.id)
      PrepareFriendFindersJob.perform
    end
  end
end
