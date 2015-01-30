require 'test_helper'

class RatingQuestionTest < ActiveSupport::TestCase
  should belong_to(:rating_system)
  should belong_to(:instance)

  should have_many(:rating_answers).dependent(:destroy)

  should validate_presence_of(:text)

  context 'validate' do
    setup do
      @rating_system = FactoryGirl.create(:rating_system)
      FactoryGirl.create_list(:rating_question, 5, rating_system: @rating_system)
    end

    context 'check_questions_quantity' do
      should 'have error message' do
        question = FactoryGirl.build(:rating_question, rating_system: @rating_system)
        assert_equal false, question.valid?
      end
    end
  end

  context 'after_create' do
    context '#create_empty_answers' do
      setup do
        @review = FactoryGirl.create(:review)
        @params = FactoryGirl.attributes_for(:rating_question, instance: @review.instance)
      end

      should 'have rating answer' do
        question = RatingQuestion.new @params
        question.save!
        assert_equal true, RatingAnswer.all.present?
        assert_equal 1, RatingAnswer.count
      end
    end
  end
end
