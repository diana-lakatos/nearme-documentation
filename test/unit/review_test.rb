require 'test_helper'

class ReviewTest < ActiveSupport::TestCase

  context 'before validation callbacks' do
    setup do
      @reviewable = FactoryGirl.create(:reservation)
    end

    should 'assign foreign keys' do
      @review = FactoryGirl.create(:review, reviewable: @reviewable, rating_system: FactoryGirl.create(:rating_system, subject: RatingConstants::HOST))
      assert_equal @reviewable.owner_id, @review.buyer_id
      assert_equal @reviewable.creator_id, @review.seller_id
      assert_equal RatingConstants::HOST, @review.subject
    end

    context 'displayable' do
      context 'TT has two sided reviews disabled' do
        should 'set to true' do
          assert FactoryGirl.create(:review).displayable
        end
      end

      context  'TT has two sided reviews enabled' do
        setup do
          TransactableType.update_all(show_reviews_if_both_completed: true)
        end

        should 'set to false if no corresponding review ' do
          refute FactoryGirl.create(:review, rating_system: FactoryGirl.create(:rating_system, subject: RatingConstants::GUEST)).displayable
        end

        should  'set to true for transactable review ' do
          assert FactoryGirl.create(:review, user: @reviewable.owner, reviewable: @reviewable, rating_system: FactoryGirl.create(:rating_system, subject: RatingConstants::TRANSACTABLE)).displayable
        end

        should  'set to true for guest review if corresponding review exists' do
          FactoryGirl.create(:review, user: @reviewable.owner, reviewable: @reviewable, rating_system: FactoryGirl.create(:rating_system, subject: RatingConstants::HOST))
          assert FactoryGirl.create(:review, user: @reviewable.creator, reviewable: @reviewable, rating_system: FactoryGirl.create(:rating_system, subject: RatingConstants::GUEST)).displayable
        end

        should  'set to true for host review if corresponding review exists' do
          FactoryGirl.create(:review, user: @reviewable.creator, reviewable: @reviewable, rating_system: FactoryGirl.create(:rating_system, subject: RatingConstants::GUEST))
          assert FactoryGirl.create(:review, user: @reviewable.owner, reviewable: @reviewable, rating_system: FactoryGirl.create(:rating_system, subject: RatingConstants::HOST)).displayable
        end

        should  'set to false if corresponding review exists but for transactable' do
          FactoryGirl.create(:review, user: @reviewable.owner, reviewable: @reviewable, rating_system: FactoryGirl.create(:rating_system, subject: RatingConstants::TRANSACTABLE))
          refute FactoryGirl.create(:review, user: @reviewable.owner, reviewable: @reviewable, rating_system: FactoryGirl.create(:rating_system, subject: RatingConstants::HOST)).displayable
        end

        should  'set to false for host review if review exists for guest but for other reviewable' do
          other_reviewable = FactoryGirl.create(:reservation, owner: @reviewable.creator)
          FactoryGirl.create(:review, user: @reviewable.creator, reviewable: other_reviewable, rating_system: FactoryGirl.create(:rating_system, subject: RatingConstants::HOST))
          refute FactoryGirl.create(:review, user: @reviewable.creator, reviewable: @reviewable, rating_system: FactoryGirl.create(:rating_system, subject: RatingConstants::GUEST)).displayable
        end
      end
    end
  end

  context "scopes" do
    setup do
      @rating_system_of_seller = FactoryGirl.create(:rating_system, subject: "host")
      @rating_system_of_product = FactoryGirl.create(:rating_system, subject: "transactable")
      @rating_system_of_buyer = FactoryGirl.create(:rating_system, subject: "guest")
    end

    context 'links' do
      setup do
        [
          @rating_system_of_seller,
          @rating_system_of_product,
          @rating_system_of_buyer
        ].each do |rs|
          FactoryGirl.create(:review, rating_system: rs)
          FactoryGirl.create(:order_review, rating_system: rs)
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
        FactoryGirl.create(:review, reviewable: @reservations.last)
        @first_review = FactoryGirl.create(:review, reviewable: @reservations.first)
      end

      should 'return reviews by reservation' do
        assert_equal @first_review, Review.by_reservations(@reservations.first.id).first
        assert_equal 2, Review.count
      end
    end

    context '.by_line_items' do
      setup do
        @line_items = FactoryGirl.create_list(:transactable_line_item, 2)
        FactoryGirl.create(:review, reviewable: @line_items.last)
        @first_review = FactoryGirl.create(:review, reviewable: @line_items.first)
      end

      should 'return reviews by reservation' do
        assert_equal @first_review, Review.by_line_items(@line_items.first.id).first
        assert_equal 2, Review.count
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
