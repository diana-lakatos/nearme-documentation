require 'test_helper'

class FindFriendsJobTest < ActiveSupport::TestCase
  context '#perform' do
    should 'trigger FriendFinder for given user and authentication' do
      Rails.application.config.expects(:perform_social_jobs).returns(true)

      authentication = stub(id: 1, user: mock(instance_id: PlatformContext.current.instance.id))
      finder_mock = mock(:find_friends!)

      Authentication.expects(:find)
        .with(authentication.id)
        .returns(authentication)
      User::FriendFinder.expects(:new)
        .with(authentication.user, authentication)
        .returns(finder_mock)

      FindFriendsJob.perform(authentication.id)
    end
  end
end
