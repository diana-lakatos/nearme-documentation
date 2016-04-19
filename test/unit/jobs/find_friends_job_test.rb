require 'test_helper'

class FindFriendsJobTest < ActiveSupport::TestCase
  context '#perform' do
    should 'trigger FriendFinder for given user and auth' do
      Rails.application.config.expects(:perform_social_jobs).returns(true)
      auth = stub(user: mock())
      finder_mock = mock(:find_friends!)
      auth.expects(:reload).returns(auth)
      User::FriendFinder.expects(:new).with(auth.user, auth).returns(finder_mock)

      FindFriendsJob.perform(auth)
    end
  end
end
