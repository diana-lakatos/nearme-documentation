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
end
