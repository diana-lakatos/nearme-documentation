require 'test_helper'

class UserReviewsServiceTest < ActiveSupport::TestCase
  context "#reviews_by_role" do
    setup do
      @user = FactoryGirl.create(:user)
      @platform_context = PlatformContext.current
    end

    should "return reviews_left_by_seller" do
      @reviewable = FactoryGirl.create(:reservation)
      review_on_buyer = create_review_for(RatingConstants::GUEST, {user: @user, reviewable: @reviewable })
      review_on_seller = create_review_for(RatingConstants::HOST, {user: @user, reviewable: @reviewable })

      params = {:option => 'reviews_left_by_seller'}
      user_reviews_service = UserReviewsService.new(@user, @platform_context, params)
      reviews_left_by_seller = user_reviews_service.reviews_by_role

      assert_equal @user.reviews.for_buyer.sort, reviews_left_by_seller.sort
      assert_includes reviews_left_by_seller, review_on_buyer
    end

    should "return reviews_left_by_buyer" do
      @reviewable = FactoryGirl.create(:reservation)
      review_on_buyer = create_review_for(RatingConstants::GUEST, {user: @user, reviewable: @reviewable })
      review_on_seller = create_review_for(RatingConstants::HOST, {user: @user, reviewable: @reviewable })
      review_on_product = create_review_for(RatingConstants::TRANSACTABLE, {user: @user, reviewable: @reviewable})
      
      params = {:option => 'reviews_left_by_buyer'}
      user_reviews_service = UserReviewsService.new(@user, @platform_context, params)
      reviews_left_by_buyer = user_reviews_service.reviews_by_role

      assert_equal @user.reviews.for_seller_and_product.sort, reviews_left_by_buyer.sort
      assert_includes reviews_left_by_buyer, review_on_seller
      assert_includes reviews_left_by_buyer, review_on_product
    end

    context "for reviews on Reservation" do
      setup do
        @owner_of_reservation = FactoryGirl.create(:user)
        @reservation = FactoryGirl.create(:reservation, owner: @owner_of_reservation, creator: FactoryGirl.create(:user))
        @reservation.update_column(:creator_id, @user.id)
      end

      should "return reviews_about_seller" do
        review = create_review_for(RatingConstants::HOST, { user: @owner_of_reservation, reviewable_id: @reservation.id, reviewable_type: @reservation.class.to_s })
        params = {:option => 'reviews_about_seller'}
        user_reviews_service = UserReviewsService.new(@user, @platform_context, params)
        reviews_about_seller = user_reviews_service.reviews_by_role

        assert_equal @user.reviews_about_seller.sort, reviews_about_seller.sort
        assert_includes reviews_about_seller, review
      end

      should "return reviews_about_buyer" do
        user = FactoryGirl.create(:user)
        review = create_review_for(RatingConstants::GUEST, { user: user, reviewable_id: @reservation.id, reviewable_type: @reservation.class.to_s })
        params = {:option => 'reviews_about_buyer'}
        user_reviews_service = UserReviewsService.new(@owner_of_reservation, @platform_context, params)
        reviews_about_buyer = user_reviews_service.reviews_by_role

        assert_equal @owner_of_reservation.reviews_about_buyer, reviews_about_buyer
        assert_includes reviews_about_buyer, review
      end
    end


    context "for reviews on Order" do
      setup do
        @buyer = FactoryGirl.create(:user)
        order = FactoryGirl.create(:order_with_line_items, user: @buyer)
        @line_item = order.line_items.first
        variant = @line_item.variant
        product = variant.product.update(user: @user)
      end

      should "return reviews_about_seller" do
        review = create_review_for(RatingConstants::HOST, {user: @buyer, reviewable_id: @line_item.id, reviewable_type: @line_item.class.to_s })
        params = {:option => 'reviews_about_seller'}
        user_reviews_service = UserReviewsService.new(@user, @platform_context, params)
        reviews_about_seller = user_reviews_service.reviews_by_role

        assert_equal @user.reviews_about_seller, reviews_about_seller
        assert_includes reviews_about_seller, review
      end

      should "return reviews_about_buyer" do
        review = create_review_for(RatingConstants::GUEST, { user: @user, reviewable_id: @line_item.id, reviewable_type: @line_item.class.to_s})
        params = {:option => 'reviews_about_buyer'}
        user_reviews_service = UserReviewsService.new(@buyer, @platform_context, params)
        reviews_about_buyer = user_reviews_service.reviews_by_role

        assert_equal @buyer.reviews_about_buyer, reviews_about_buyer
        assert_includes reviews_about_buyer, review
      end
    end
  end

  context "#rating_questions_by_role" do
    setup do
      @instance = FactoryGirl.create(:instance, generate_rating_systems: false)
      PlatformContext.current = PlatformContext.new(@instance)
      @platform_context = PlatformContext.current
    end

    should "return rating_questions for lessor rating system" do
      rating_system = FactoryGirl.create(:active_rating_system, subject: @platform_context.instance.lessor, instance: @instance )
      rating_questions = (1..2).map { FactoryGirl.create(:rating_question, rating_system: rating_system, instance: @instance ) }
      params = {:option => 'reviews_about_seller'}
      @user_reviews_service = UserReviewsService.new(@user, @platform_context, params)
      rating_questions_by_role = @user_reviews_service.rating_questions_by_role

      assert_equal rating_questions, rating_questions_by_role
    end

    should "return rating_questions for lessee rating system" do
      rating_system = FactoryGirl.create(:active_rating_system, subject: @platform_context.instance.lessee, instance: @instance )
      rating_questions = (1..2).map { FactoryGirl.create(:rating_question, rating_system: rating_system, instance: @instance ) }
      params = {:option => 'reviews_about_buyer'}
      @user_reviews_service = UserReviewsService.new(@user, @platform_context, params)
      rating_questions_by_role = @user_reviews_service.rating_questions_by_role

      assert_equal rating_questions, rating_questions_by_role
    end
  end

  def create_review_for(type, opts={})
    rs = FactoryGirl.create(:rating_system, subject: type)
    FactoryGirl.create(:review, opts.merge({ rating_system_id: rs.id }))
  end
end