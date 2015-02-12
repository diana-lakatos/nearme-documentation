require 'test_helper'

class ReviewTest < ActiveSupport::TestCase
  should belong_to(:instance)
  should belong_to(:reviewable)
  should belong_to(:user)
  should belong_to(:transactable_type)

  should have_many(:rating_answers).dependent(:destroy)

  should validate_presence_of(:rating)
  should validate_presence_of(:object)
  should validate_presence_of(:user)
  should validate_presence_of(:reviewable)
  should validate_presence_of(:transactable_type)

  should ensure_length_of(:comment).is_at_most(255)
  should validate_inclusion_of(:rating).in_range(RatingConstants::VALID_VALUES).with_message('Rating is required')

  context "#scopes" do
    context '#with_object' do
      setup do
        @review_of_seller = FactoryGirl.create(:review, object: 'seller')
        @review_of_product = FactoryGirl.create(:review, object: 'product')
      end

      should 'select only review of seller' do
        reviews_of_seller = Review.with_object('seller')
        assert_equal 1, reviews_of_seller.count
        assert_equal reviews_of_seller.first, @review_of_seller
      end

      should 'select only review of product' do
        reviews_of_product = Review.with_object('product')
        assert_equal 1, reviews_of_product.count
        assert_equal reviews_of_product.first, @review_of_product
      end

    end

    context '#with_rating' do
      setup do
        @review_5_stars = FactoryGirl.create(:review, rating: '5')
        @review_3_stars = FactoryGirl.create(:review, rating: '3')
      end

      should 'select only reviews with 5 rating' do
        @reviews_5_stars = Review.with_rating('5')
        assert_equal 1, @reviews_5_stars.count
        assert_equal @reviews_5_stars.first, @review_5_stars
      end

      should 'select only reviews with 3 rating' do
        @reviews_3_stars = Review.with_rating('3')
        assert_equal 1, @reviews_3_stars.count
        assert_equal @reviews_3_stars.first, @review_3_stars
      end
    end

    context '#with_date' do
      setup do
        @today_review = FactoryGirl.create(:review)
        @today_review.update_attribute(:created_at, Time.zone.today)
        @yesterday_review = FactoryGirl.create(:review)
        @yesterday_review.update_attribute(:created_at, Time.zone.today.yesterday)
      end

      should "select only today's reviews" do
        @todays_reviews = Review.with_date(Time.zone.today)
        assert_equal 1, @todays_reviews.count
        assert_equal @todays_reviews.first, @today_review
      end

      should "select only yesterday's reviews" do
        @yesterdays_reviews = Review.with_date(Time.zone.today.yesterday)
        assert_equal 1, @yesterdays_reviews.count
        assert_equal @yesterdays_reviews.first, @yesterday_review
      end
    end

    context '#by_reservations' do
      setup do
        @reservations = FactoryGirl.create_list(:reservation, 2)
        @first_review = FactoryGirl.create(:review, reviewable: @reservations.first)
        second_review = FactoryGirl.create(:review, reviewable: @reservations.last)
      end

      should 'return reviews by reservation' do
        assert_equal @first_review, Review.by_reservations(@reservations.first.id).first
        assert_equal 2, Review.count
      end
    end

    context '#by_line_items' do
      setup do
        @line_items = FactoryGirl.create_list(:line_item, 2)
        @first_review = FactoryGirl.create(:review, reviewable: @line_items.first)
        second_review = FactoryGirl.create(:review, reviewable: @line_items.last)
      end

      should 'return reviews by reservation' do
        assert_equal @first_review, Review.by_line_items(@line_items.first.id).first
        assert_equal 2, Review.count
      end
    end
  end
end
