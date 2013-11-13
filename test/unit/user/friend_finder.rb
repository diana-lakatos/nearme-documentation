require 'test_helper'

class User::FriendFinderTest < ActiveSupport::TestCase
  context 'unit' do
    setup do
      @user = stub
      @authentication = stub
      @authentications = [@authentication]
      @ff = User::FriendFinder.new(@user, @authentications)
    end

    context 'initialize' do
      should 'assign user and authentications' do
        assert_equal @user, @ff.user
        assert_equal @authentications, @ff.authentications
      end
    end

    context 'find_friends!' do
      should 'call authentications and add_friend' do
        friend = stub

        @authentication.expects(:new_connections).returns([friend])
        @ff.user.expects(:add_friend).with(friend)

        @ff.find_friends!
      end
    end
  end

  context 'integration' do
    setup do
      @me = FactoryGirl.create(:user)
      @auth = FactoryGirl.build(:authentication, provider: 'facebook', token_expires_at: Time.now + 60.days, token_expired: false)
      @me.authentications << @auth
    end

    context 'find new friends' do
      should 'add new friends once' do
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
          User::FriendFinder.new(@me, @auth).find_friends!
        end 

        assert_difference('@me.friends.count', 0) do
          User::FriendFinder.new(@me, @auth).find_friends!
        end 
      end

      should 'catch and mark expired token' do
        connection_stub = stub()
        connection_stub.expects(:get_connections).raises(Koala::Facebook::AuthenticationError.new({}, ''))
        Authentication::FacebookProvider.any_instance.expects(:connection).returns(connection_stub)
        refute @auth.token_expired?
        User::FriendFinder.new(@me, @auth).find_friends!
        assert @auth.reload.token_expired?
      end
    end
  end
end
