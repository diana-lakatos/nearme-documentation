require 'test_helper'

class RatingTest < ActiveSupport::TestCase
  test "it exists" do
    assert Rating
  end

  test "it has a listing" do
    @rating = Rating.new
    @rating.content = FactoryGirl.create(:listing)

    assert @rating.content
  end
end
