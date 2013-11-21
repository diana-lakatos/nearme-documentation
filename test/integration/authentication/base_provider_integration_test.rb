require 'test_helper'

class Authentication::BaseProviderIntegrationTest < ActiveSupport::TestCase

  context 'new connections' do
    should 'find new friends' do
      @me = FactoryGirl.create(:user)
      @auth = FactoryGirl.build(:authentication, provider: 'facebook')
      @me.authentications << @auth

      @friends = []
      3.times {
        friend = FactoryGirl.create(:user)
        friend.authentications << FactoryGirl.create(:authentication, provider: 'facebook')
        @me.add_friend(friend)
        @friends << friend
      }

      @social_friends = []
      3.times {
        friend = FactoryGirl.create(:user)
        friend.authentications << FactoryGirl.create(:authentication, provider: 'facebook')
        @social_friends << friend
      }

      friend_ids = (@friends + @social_friends).collect(&:authentications).flatten.collect(&:uid)

      @auth.social_connection.stubs(:friend_ids).returns(friend_ids)

      social_friends_ids = @social_friends.collect(&:id).sort
      new_friends_ids = @auth.social_connection.new_connections.collect(&:id).sort
      assert_equal social_friends_ids, new_friends_ids
    end
  end
end
