require 'test_helper'

class User::FriendFinderTest < ActiveSupport::TestCase
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
