require 'test_helper'

class UserIntegrationTest < ActiveSupport::TestCase
  context 'visited_listing' do
    should 'find only users with confirmed past reservation for listing' do
      @listing = FactoryGirl.create(:listing)
      @me = FactoryGirl.create(:user)
      FactoryGirl.create(:reservation, state: 'confirmed')

      4.times { @me.friends << FactoryGirl.create(:user) }

      friends_with_visit = @me.friends.first(2)
      @me.friends.last.reservations << FactoryGirl.create(:future_reservation, state: 'confirmed', date: Date.tomorrow)
      friends_with_visit.each {|f| FactoryGirl.create(:past_reservation, state: 'confirmed', listing: @listing, user:f)}
      
      assert_equal friends_with_visit.sort, @me.friends.visited_listing(@listing).to_a.sort
    end
  end
end
