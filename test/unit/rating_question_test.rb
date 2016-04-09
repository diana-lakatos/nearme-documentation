require 'test_helper'

class RatingQuestionTest < ActiveSupport::TestCase
  should belong_to(:rating_system)
  should belong_to(:instance)

  should have_many(:rating_answers).dependent(:destroy)

  should validate_presence_of(:text)

  setup do
    @rating_system = FactoryGirl.create(:rating_system)
  end

  context 'after_create' do
    context '#create_empty_answers' do
      setup do
        @review = FactoryGirl.create(:review, rating_system: @rating_system)
        @review_other = FactoryGirl.create(:review)
        @params = FactoryGirl.attributes_for(:rating_question, rating_system_id: @rating_system.id, instance: @review.instance)
      end

      should 'have rating answer' do
        RatingQuestion.create!(@params)
        assert_equal 0, @review_other.rating_answers.count
        assert_equal 1, @review.rating_answers.count

      end
    end
  end
end
