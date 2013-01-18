require 'test_helper'

class ListingTest < ActiveSupport::TestCase

  should belong_to(:location)
  should belong_to(:creator)
  should have_many(:reservations)
  should have_many(:ratings)
  should have_many(:unit_prices)

  should validate_presence_of(:location_id)
  should validate_presence_of(:creator_id)
  should validate_presence_of(:name)
  should validate_presence_of(:description)
  should validate_presence_of(:quantity)
  should ensure_inclusion_of(:confirm_reservations).in_array([true,false])
  should validate_numericality_of(:quantity)
  should allow_value('x' * 250).for(:description)
  should_not allow_value('x' * 251).for(:description)

end
