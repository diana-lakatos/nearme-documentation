require 'test_helper'

class UserIntegrationTest < ActiveSupport::TestCase
  context 'visited_listing' do
    should 'find only users with confirmed past reservation for listing in friends' do
      @listing = FactoryGirl.create(:listing)
      @me = FactoryGirl.create(:user)
      FactoryGirl.create(:reservation, state: 'confirmed')

      4.times { @me.add_friend(FactoryGirl.create(:user)) }

      friends_with_visit = @me.friends.first(2)
      @me.friends.last.reservations << FactoryGirl.create(:future_reservation, state: 'confirmed', date: Date.tomorrow)
      friends_with_visit.each {|f| FactoryGirl.create(:past_reservation, state: 'confirmed', listing: @listing, user:f)}

      assert_equal friends_with_visit.sort, @me.friends.visited_listing(@listing).to_a.sort
    end
  end

  context 'hosts_of_listing' do
    should 'find host of listing in friends' do
      @me = FactoryGirl.create(:user)
      @listing = FactoryGirl.create(:listing)
      @listing.location.administrator = friend1 = FactoryGirl.create(:user)
      @listing.save!
      friend2 = FactoryGirl.create(:user)
      @me.add_friends(friend1, friend2)

      assert_equal [friend1].sort, @me.friends.hosts_of_listing(@listing).sort
    end
  end

  context 'know_host_of' do
    should 'find users knows host' do
      @me = FactoryGirl.create(:user)
      2.times { @me.add_friend(FactoryGirl.create(:user))}
      @friend = FactoryGirl.create(:user)

      @me.add_friend(@friend)

      @listing = FactoryGirl.create(:listing)
      @listing.location.administrator = host = FactoryGirl.create(:user)
      @listing.save!

      @friend.add_friend(host)

      assert_equal [@friend], @me.friends_know_host_of(@listing)
    end
  end
end
