require 'test_helper'

class ReviewTest < ActiveSupport::TestCase
  should belong_to(:instance)
  should belong_to(:reviewable)
  should belong_to(:user)
  should belong_to(:transactable_type)

  should have_many(:rating_answers).dependent(:destroy)

  should validate_presence_of(:rating)
  should validate_presence_of(:user)
  should validate_presence_of(:reviewable)
  should validate_presence_of(:transactable_type)

  should validate_inclusion_of(:rating).in_range(RatingConstants::VALID_VALUES).with_message('Rating is required')

  context "scopes" do
    setup do
      @rating_system_of_seller = FactoryGirl.create(:rating_system, subject: "host")
      @rating_system_of_product = FactoryGirl.create(:rating_system, subject: "transactable")
      @rating_system_of_buyer = FactoryGirl.create(:rating_system, subject: "guest")
    end

    context '.with_object' do
      setup do
        @review_of_seller = FactoryGirl.create(:review, rating_system_id: @rating_system_of_seller.id)
        @review_of_product = FactoryGirl.create(:review, rating_system_id: @rating_system_of_product.id)
        @review_of_buyer = FactoryGirl.create(:review, rating_system_id: @rating_system_of_buyer.id)        
      end

      should 'select only review of seller' do
        reviews_of_seller = Review.with_object(RatingConstants::SELLER)
        assert_equal 1, reviews_of_seller.count
        assert_equal reviews_of_seller.first, @review_of_seller
      end

      should 'select only review of product' do
        reviews_of_product = Review.with_object(RatingConstants::PRODUCT)
        assert_equal 1, reviews_of_product.count
        assert_equal reviews_of_product.first, @review_of_product
      end

      should 'select only review of buyer' do
        reviews_of_buyer = Review.with_object(RatingConstants::BUYER)
        assert_equal 1, reviews_of_buyer.count
        assert_equal reviews_of_buyer.first, @review_of_buyer
      end
    end

    context 'links' do
      setup do
        [
          @rating_system_of_seller, 
          @rating_system_of_product, 
          @rating_system_of_buyer
        ].each do |rs| 
          FactoryGirl.create(:review, rating_system_id: rs.id)
          FactoryGirl.create(:order_review, rating_system_id: rs.id)
        end
        
        @reviews = Review.all
      end

      should 'link properly' do
        @reviews.each { |review| assert_link_presence(review) }
      end

      should 'create link even when reviewable is missing' do
        @reviews.each do |review|
          review.reviewable.destroy
          review.reload
          assert_missing_link(review)
        end
      end
    end

    context '.with_rating' do
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

    context '.with_date' do
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

    context '.by_reservations' do
      setup do
        @reservations = FactoryGirl.create_list(:reservation, 2)
        @first_review = FactoryGirl.create(:review, reviewable_id: @reservations.first.id, reviewable_type: @reservations.first.class.to_s)
        second_review = FactoryGirl.create(:review, reviewable_id: @reservations.last.id, reviewable_type: @reservations.last.class.to_s)
      end

      should 'return reviews by reservation' do
        assert_equal @first_review, Review.by_reservations(@reservations.first.id).first
        assert_equal 2, Review.count
      end
    end

    context '.by_line_items' do
      setup do
        @line_items = FactoryGirl.create_list(:line_item, 2)
        @first_review = FactoryGirl.create(:review, reviewable_id: @line_items.first.id, reviewable_type: @line_items.first.class.to_s)
        second_review = FactoryGirl.create(:review, reviewable_id: @line_items.last.id, reviewable_type: @line_items.last.class.to_s)
      end

      should 'return reviews by reservation' do
        assert_equal @first_review, Review.by_line_items(@line_items.first.id).first
        assert_equal 2, Review.count
      end
    end

    context ".both_sides_reviewed_for" do
      setup do
        Review.destroy_all

        @host = FactoryGirl.create(:user)
        @guest = FactoryGirl.create(:user)
        
        @host_rating_system_id = FactoryGirl.create(:rating_system, subject: "host").id
        @guest_rating_system_id = FactoryGirl.create(:rating_system, subject: "guest").id

        @reviewable = FactoryGirl.create(:reservation)
        @reviewable2 = FactoryGirl.create(:reservation)

      end

      should 'not show reviews if host havent reviewed guest' do
        assert_empty Review.both_sides_reviewed_for(RatingConstants::SELLER, @host.id)
        assert_empty Review.both_sides_reviewed_for(RatingConstants::BUYER, @guest.id)

        FactoryGirl.create(:review, user_id: @guest.id, rating_system_id: @host_rating_system_id, reviewable: @reviewable)

        assert_empty Review.both_sides_reviewed_for(RatingConstants::SELLER, @host.id)
        assert_empty Review.both_sides_reviewed_for(RatingConstants::BUYER, @guest.id)

        FactoryGirl.create(:review, user_id: @host.id, rating_system_id: @guest_rating_system_id, reviewable: @reviewable)

        assert_equal Review.both_sides_reviewed_for(RatingConstants::SELLER, @host.id).count, 1
        assert_equal Review.both_sides_reviewed_for(RatingConstants::BUYER, @guest.id).count, 1

        FactoryGirl.create(:review, user_id: @guest.id, rating_system_id: @host_rating_system_id, reviewable: @reviewable2)

        assert_equal Review.both_sides_reviewed_for(RatingConstants::SELLER, @host.id).count, 1
        assert_equal Review.both_sides_reviewed_for(RatingConstants::BUYER, @guest.id).count, 1

        FactoryGirl.create(:review, user_id: @host.id, rating_system_id: @guest_rating_system_id, reviewable: @reviewable2)

        assert_equal Review.both_sides_reviewed_for(RatingConstants::SELLER, @host.id).count, 2
        assert_equal Review.both_sides_reviewed_for(RatingConstants::BUYER, @guest.id).count, 2
      end
    end
  end

  def assert_link_presence(review)
    assert review.decorate.link_to_object.present?
  end

  def assert_missing_link(review)
    assert I18n.t('instance_admin.manage.reviews.index.missing'), review.decorate.link_to_object
  end
end
