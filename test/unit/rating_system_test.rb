require 'test_helper'

class RatingSystemTest < ActiveSupport::TestCase
  should belong_to(:instance)
  should have_many(:rating_hints).dependent(:destroy)
  should have_many(:rating_questions).dependent(:destroy)

  should accept_nested_attributes_for(:rating_questions).allow_destroy(true)
  should accept_nested_attributes_for(:rating_hints)
end
