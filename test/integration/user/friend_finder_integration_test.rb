require 'test_helper'

class User::FriendFinderIntegrationTest < ActiveSupport::TestCase
  context 'find new friends' do
    should 'add new friends once' do
      @me = FactoryGirl.create(:user)
      @auth = FactoryGirl.build(:authentication, provider: 'facebook', token_expires_at: Time.now + 60.days)
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

      Authentication::FacebookProvider.any_instance.stubs(:friend_ids).returns(friend_ids)
     
      assert_difference('@me.friends.count', 3) do
        @me.find_new_friends!
      end 

      assert_difference('@me.friends.count', 0) do
        @me.find_new_friends!
      end 
    end
  end
end
