require 'test_helper'

class UserReviewsServiceTest < ActiveSupport::TestCase
  context 'reviews by role' do
    setup do
      @host_listing = FactoryGirl.create(:transactable)
      @guest_listing = FactoryGirl.create(:transactable)
      @reservation = FactoryGirl.create(:reservation, transactable: @host_listing, user: @guest_listing.creator)
      @other_reservation = FactoryGirl.create(:reservation, transactable: @guest_listing, user: @host_listing.creator)
    end

    context '#reviews_by_role if no both sides reviews' do
      should 'reviews_by_role returns proper result for all options if both reviewed is false' do
        @reviews = create_reviews
        assert_equal reviews_ids([:host_rates_guest]), reviews_by_role(@reservation.creator, 'reviews_left_by_seller')
        assert_equal reviews_ids([:guest_rates_as_host_other_guest]), reviews_by_role(@reservation.owner, 'reviews_left_by_seller')

        assert_equal reviews_ids([:host_rates_as_guest_other_host]), reviews_by_role(@reservation.creator, 'reviews_left_by_buyer')
        assert_equal reviews_ids([:host_rates_as_guest_other_transactable]), reviews_by_role(@reservation.creator, 'reviews_left_about_product')
        assert_equal reviews_ids([:guest_rates_host]), reviews_by_role(@reservation.owner, 'reviews_left_by_buyer')

        assert_equal reviews_ids([:guest_rates_host]), reviews_by_role(@reservation.creator, 'reviews_about_seller')
        assert_equal reviews_ids([:host_rates_as_guest_other_host]), reviews_by_role(@reservation.owner, 'reviews_about_seller')

        assert_equal reviews_ids([:guest_rates_as_host_other_guest]), reviews_by_role(@reservation.creator, 'reviews_about_buyer')
        assert_equal reviews_ids([:host_rates_guest]), reviews_by_role(@reservation.owner, 'reviews_about_buyer')
      end

      should "still display guest reviews if host hasn't reviewed" do
        @reviews = create_reviews_without_host_rates_guest
        assert_equal reviews_ids([]), reviews_by_role(@reservation.creator, 'reviews_left_by_seller')
        assert_equal reviews_ids([:guest_rates_as_host_other_guest]), reviews_by_role(@reservation.owner, 'reviews_left_by_seller')

        assert_equal reviews_ids([:host_rates_as_guest_other_host]), reviews_by_role(@reservation.creator, 'reviews_left_by_buyer')
        assert_equal reviews_ids([:host_rates_as_guest_other_transactable]), reviews_by_role(@reservation.creator, 'reviews_left_about_product')
        assert_equal reviews_ids([:guest_rates_host]), reviews_by_role(@reservation.owner, 'reviews_left_by_buyer')

        assert_equal reviews_ids([:guest_rates_host]), reviews_by_role(@reservation.creator, 'reviews_about_seller')
        assert_equal reviews_ids([:host_rates_as_guest_other_host]), reviews_by_role(@reservation.owner, 'reviews_about_seller')

        assert_equal reviews_ids([:guest_rates_as_host_other_guest]), reviews_by_role(@reservation.creator, 'reviews_about_buyer')
        assert_equal reviews_ids([]), reviews_by_role(@reservation.owner, 'reviews_about_buyer')
      end
    end

    context '#reviews_by_role if no both sides reviews' do
      setup do
        TransactableType.update_all(show_reviews_if_both_completed: true)
      end

      should 'change nothing if everyone reviewed everything' do
        @reviews = create_reviews
        assert_equal reviews_ids([:host_rates_guest]), reviews_by_role(@reservation.creator, 'reviews_left_by_seller')
        assert_equal reviews_ids([:guest_rates_as_host_other_guest]), reviews_by_role(@reservation.owner, 'reviews_left_by_seller')

        assert_equal reviews_ids([:host_rates_as_guest_other_host]), reviews_by_role(@reservation.creator, 'reviews_left_by_buyer')
        assert_equal reviews_ids([:host_rates_as_guest_other_transactable]), reviews_by_role(@reservation.creator, 'reviews_left_about_product')
        assert_equal reviews_ids([:guest_rates_host]), reviews_by_role(@reservation.owner, 'reviews_left_by_buyer')

        assert_equal reviews_ids([:guest_rates_host]), reviews_by_role(@reservation.creator, 'reviews_about_seller')
        assert_equal reviews_ids([:host_rates_as_guest_other_host]), reviews_by_role(@reservation.owner, 'reviews_about_seller')

        assert_equal reviews_ids([:guest_rates_as_host_other_guest]), reviews_by_role(@reservation.creator, 'reviews_about_buyer')
        assert_equal reviews_ids([:host_rates_guest]), reviews_by_role(@reservation.owner, 'reviews_about_buyer')
      end

      should 'do not display host and guest ratings if host rating is missing' do
        @reviews = create_reviews_without_guest_rates_host
        assert_equal reviews_ids([]), reviews_by_role(@reservation.creator, 'reviews_left_by_seller')
        assert_equal reviews_ids([:guest_rates_as_host_other_guest]), reviews_by_role(@reservation.owner, 'reviews_left_by_seller')

        assert_equal reviews_ids([:host_rates_as_guest_other_host]), reviews_by_role(@reservation.creator, 'reviews_left_by_buyer')
        assert_equal reviews_ids([:host_rates_as_guest_other_transactable]), reviews_by_role(@reservation.creator, 'reviews_left_about_product')
        assert_equal reviews_ids([]), reviews_by_role(@reservation.owner, 'reviews_left_by_buyer')

        assert_equal reviews_ids([]), reviews_by_role(@reservation.creator, 'reviews_about_seller')
        assert_equal reviews_ids([:host_rates_as_guest_other_host]), reviews_by_role(@reservation.owner, 'reviews_about_seller')

        assert_equal reviews_ids([:guest_rates_as_host_other_guest]), reviews_by_role(@reservation.creator, 'reviews_about_buyer')
        assert_equal reviews_ids([]), reviews_by_role(@reservation.owner, 'reviews_about_buyer')
      end

      should 'do not display host and guest ratings if guest rating is missing' do
        @reviews = create_reviews_without_host_rates_guest
        assert_equal reviews_ids([]), reviews_by_role(@reservation.creator, 'reviews_left_by_seller')
        assert_equal reviews_ids([:guest_rates_as_host_other_guest]), reviews_by_role(@reservation.owner, 'reviews_left_by_seller')

        assert_equal reviews_ids([:host_rates_as_guest_other_host]), reviews_by_role(@reservation.creator, 'reviews_left_by_buyer')
        assert_equal reviews_ids([:host_rates_as_guest_other_transactable]), reviews_by_role(@reservation.creator, 'reviews_left_about_product')
        assert_equal reviews_ids([]), reviews_by_role(@reservation.owner, 'reviews_left_by_buyer')

        assert_equal reviews_ids([]), reviews_by_role(@reservation.creator, 'reviews_about_seller')
        assert_equal reviews_ids([:host_rates_as_guest_other_host]), reviews_by_role(@reservation.owner, 'reviews_about_seller')

        assert_equal reviews_ids([:guest_rates_as_host_other_guest]), reviews_by_role(@reservation.creator, 'reviews_about_buyer')
        assert_equal reviews_ids([]), reviews_by_role(@reservation.owner, 'reviews_about_buyer')
      end
    end
  end

  context 'for reviews on Order' do
    setup do
      @buyer = FactoryGirl.create(:user)
      order = FactoryGirl.create(:purchase, user: @buyer)
      @user = order.transactable_line_items.first.line_item_source.company.creator
      @line_item = order.transactable_line_items.first
    end

    should 'return reviews_about_seller' do
      review = create_review_for(RatingConstants::HOST, user: @buyer, reviewable_id: @line_item.id, reviewable_type: @line_item.class.to_s)
      user_reviews_service = UserReviewsService.new(@user, option: 'reviews_about_seller')
      assert_equal [review.id], user_reviews_service.reviews_by_role.pluck(:id).sort
    end

    should 'return reviews_about_buyer' do
      review = create_review_for(RatingConstants::GUEST, user: @user, reviewable_id: @line_item.id, reviewable_type: @line_item.class.to_s)
      user_reviews_service = UserReviewsService.new(@buyer, option: 'reviews_about_buyer')
      assert_equal [review.id], user_reviews_service.reviews_by_role.pluck(:id).sort
    end
  end

  protected

  def create_review_for(type, opts = {})
    rs = FactoryGirl.create(:rating_system, subject: type)
    FactoryGirl.create(:review, opts.merge(rating_system_id: rs.id))
  end

  def create_reviews
    reviews = {}
    reviews[:host_rates_guest] = create_review_for(RatingConstants::GUEST, user: @host_listing.creator, reviewable: @reservation)
    reviews[:guest_rates_host] = create_review_for(RatingConstants::HOST, user: @guest_listing.creator, reviewable: @reservation)
    reviews[:guest_rates_transactable] = create_review_for(RatingConstants::TRANSACTABLE, user: @guest_listing.creator, reviewable: @reservation)
    reviews[:host_rates_as_guest_other_transactable] = create_review_for(RatingConstants::TRANSACTABLE, user: @host_listing.creator, reviewable: @other_reservation)
    reviews[:guest_rates_as_host_other_guest] = create_review_for(RatingConstants::GUEST, user: @guest_listing.creator, reviewable: @other_reservation)
    reviews[:host_rates_as_guest_other_host] = create_review_for(RatingConstants::HOST, user: @host_listing.creator, reviewable: @other_reservation)
    reviews
  end

  def create_reviews_without_guest_rates_host
    reviews = {}
    reviews[:host_rates_guest] = create_review_for(RatingConstants::GUEST, user: @host_listing.creator, reviewable: @reservation)
    reviews[:guest_rates_transactable] = create_review_for(RatingConstants::TRANSACTABLE, user: @guest_listing.creator, reviewable: @reservation)
    reviews[:host_rates_as_guest_other_transactable] = create_review_for(RatingConstants::TRANSACTABLE, user: @host_listing.creator, reviewable: @other_reservation)
    reviews[:guest_rates_as_host_other_guest] = create_review_for(RatingConstants::GUEST, user: @guest_listing.creator, reviewable: @other_reservation)
    reviews[:host_rates_as_guest_other_host] = create_review_for(RatingConstants::HOST, user: @host_listing.creator, reviewable: @other_reservation)
    reviews
  end

  def create_reviews_without_host_rates_guest
    reviews = {}
    reviews[:guest_rates_host] = create_review_for(RatingConstants::HOST, user: @guest_listing.creator, reviewable: @reservation)
    reviews[:guest_rates_transactable] = create_review_for(RatingConstants::TRANSACTABLE, user: @guest_listing.creator, reviewable: @reservation)
    reviews[:host_rates_as_guest_other_transactable] = create_review_for(RatingConstants::TRANSACTABLE, user: @host_listing.creator, reviewable: @other_reservation)
    reviews[:guest_rates_as_host_other_guest] = create_review_for(RatingConstants::GUEST, user: @guest_listing.creator, reviewable: @other_reservation)
    reviews[:host_rates_as_guest_other_host] = create_review_for(RatingConstants::HOST, user: @host_listing.creator, reviewable: @other_reservation)
    reviews
  end

  def reviews_ids(symbols)
    symbols.inject([]) do |arr, symbol|
      arr << @reviews[symbol].id
    end.sort
  end

  def reviews_by_role(user, role)
    UserReviewsService.new(user, option: role).reviews_by_role.pluck(:id).sort.uniq
  end
end
