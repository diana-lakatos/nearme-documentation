require 'test_helper'

class UserRelationshipTest < ActiveSupport::TestCase

  should belong_to(:follower)
  should belong_to(:followed)

  context 'User#add_friend' do
    setup do
      @jimmy = FactoryGirl.create(:user)
      @joe = FactoryGirl.create(:user)
    end

    should 'creates two way relationship' do
      @jimmy.add_friend(@joe)

      assert_equal [@joe], @jimmy.friends
      assert_equal [@jimmy], @joe.friends
    end
  end

  context 'User#find_new_friends' do
    setup do
      @jimmy = FactoryGirl.create(:user)
      5.times { @jimmy.add_friend(FactoryGirl.create(:user)) }
      @john = FactoryGirl.create(:user)
      @sai  = FactoryGirl.create(:user)
    end

    should 'find only unlinked users' do
      all_users = User.all
      new_friends = @jimmy.find_new_friends(all_users)

      assert_equal all_users.count - 6, new_friends.count
      assert new_friends.include?(@john)
      assert new_friends.include?(@sai)
    end
  end
end
