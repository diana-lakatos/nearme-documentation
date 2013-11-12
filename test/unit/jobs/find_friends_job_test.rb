require 'test_helper'

class FindFriendsJobTest < ActiveSupport::TestCase
  context '#perform' do
    should 'trigger FriendFinder for given user and auth' do
      auth = stub(user: mock())
      finder_mock = mock(:find_friends!)
      User::FriendFinder.expects(:new).with(auth.user, auth).returns(finder_mock)

      FindFriendsJob.new(auth).perform
    end
  end
end
