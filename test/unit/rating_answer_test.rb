require 'test_helper'

class RatingAnswerTest < ActiveSupport::TestCase
  should belong_to(:rating_question)
  should belong_to(:review)

  should validate_presence_of(:rating_question_id)
  should validate_presence_of(:review_id)

  should validate_inclusion_of(:rating).in_range(RatingConstants::VALID_VALUES).allow_blank
end
