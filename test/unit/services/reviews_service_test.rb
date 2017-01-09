require 'test_helper'

class ReviewsServiceTest < ActiveSupport::TestCase
  context '#get_by' do
    setup do
      @review_5_stars = FactoryGirl.create(:review, rating: '5')
      @review_3_stars = FactoryGirl.create(:review, rating: '3')
      user = @review_5_stars.user
      @reviews_service = ReviewsService.new(user, rating: ['5'], date: '')
    end

    should 'return reviews' do
      reviews = @reviews_service.get_reviews
      assert_equal 1, reviews.size
      assert_equal @review_5_stars, reviews.first
    end
  end

  context '#generate_csv_for' do
    setup do
      @reviews = FactoryGirl.create_list(:review, 2)
      columns = *%w(id rating user_name created_at)
      @review_1 = @reviews.first.attributes.values_at(columns).join(',')
      @review_2 = @reviews.last.attributes.values_at(columns).join(',')
      user = @reviews.first.user
      instance = @reviews.first.instance
      @reviews_service = ReviewsService.new(user, instance)
    end

    should 'return csv with reviews' do
      csv = ReviewsService.generate_csv_for(@reviews)
      assert csv.include?(@review_1)
      assert csv.include?(@review_2)
    end
  end

  context '#filter_period' do
    setup do
      @user = FactoryGirl.create(:user)
      @reviews_service = ReviewsService.new(@user, rating: ['5'], date: '')
    end

    should 'return period for 6 month' do
      reviews_service = ReviewsService.new(@user, period: '6_months')
      period = reviews_service.filter_period
      assert_equal 6.months.ago.to_date, period
    end

    should 'return period for 2014 year' do
      reviews_service = ReviewsService.new(@user, period: '2014')
      period = reviews_service.filter_period
      assert_equal [DateTime.new(2014).to_date, DateTime.new(2014).end_of_year.to_date], period
    end

    should 'return period for 2013 year' do
      reviews_service = ReviewsService.new(@user, period: '2013')
      period = reviews_service.filter_period
      assert_equal [DateTime.new(2013).to_date, DateTime.new(2013).end_of_year.to_date], period
    end

    should 'return period for 2012 year' do
      reviews_service = ReviewsService.new(@user, period: '2012')
      period = reviews_service.filter_period
      assert_equal [DateTime.new(2012).to_date, DateTime.new(2012).end_of_year.to_date], period
    end

    should 'return period for 2011 year' do
      reviews_service = ReviewsService.new(@user, period: '2011')
      period = reviews_service.filter_period
      assert_equal [DateTime.new(2011).to_date, DateTime.new(2011).end_of_year.to_date], period
    end

    should 'return period for 30 days without param' do
      reviews_service = ReviewsService.new(@user)
      period = reviews_service.filter_period
      assert_equal 30.days.ago.to_date, period
    end

    should 'return period for 30 days with param' do
      reviews_service = ReviewsService.new(@user, period: '30_days')
      period = reviews_service.filter_period
      assert_equal 30.days.ago.to_date, period
    end
  end

  context '#get_rating_systems' do
    setup do
      @reviews_service = ReviewsService.new(FactoryGirl.create(:user))
    end

    should 'return rating systems' do
      tt = FactoryGirl.create(:transactable_type)
      @rating_system = FactoryGirl.create(:rating_system, transactable_type: tt)
      assert_equal @rating_system, @reviews_service.get_rating_systems[:active_rating_systems][tt.id].first
    end
  end

  context '#get_line_items_for_owner_and_creator' do
    setup do
      @order = create(:purchase, state: 'confirmed', archived_at: Time.now)
      @order2 = create(:purchase, state: 'confirmed', archived_at: Time.now)
      @line_items = @order.transactable_line_items

      @line_items.each do |line_item|
        transactable = line_item.line_item_source
        transactable.creator = FactoryGirl.create(:user)
        transactable.save!
      end
      @line_items.first.line_item_source.transactable_type.create_rating_systems
      @line_items.first.line_item_source.transactable_type.rating_systems.update_all(active: true)
      user = @order.user

      @reviews_service = ReviewsService.new(user)
    end

    should 'return line items if order is reviewable' do
      result = @reviews_service.get_line_items_for_owner_and_creator
      assert_equal @line_items.count, result[RatingConstants::HOST].count
    end

    should 'not return line items if order is not reviewable' do
      @order.update_column(:state, 'unconfirmed')
      result = @reviews_service.get_line_items_for_owner_and_creator
      assert_equal 0, result[RatingConstants::GUEST].count
    end
  end

  context '#get_reservations_for_owner_and_creator' do
    setup do
      @reservation = FactoryGirl.create(:reviewable_reservation)
      user = @reservation.creator
      @reviews_service = ReviewsService.new(user)
    end

    should 'return reservations' do
      result = @reviews_service.get_line_items_for_owner_and_creator
      assert_equal result[RatingConstants::GUEST].first, @reservation.transactable_line_items.first
    end
  end

  context '#get_reviews_by' do
    setup do
      user = FactoryGirl.create(:user)
      @reservation = FactoryGirl.create(:reviewable_reservation, user: user)
      @reservations = { RatingConstants::HOST => user.orders.reservations, RatingConstants::GUEST => user.orders.reservations }
      @review = create(:review, rating_system: FactoryGirl.create(:rating_system, subject: RatingConstants::HOST), reviewable: @reservation, user: user)
      @reviews_service = ReviewsService.new(user)
    end

    should 'return reviews' do
      result = @reviews_service.get_reviews_by(@reservations)
      assert_equal result[:seller_collection].first, @review
    end
  end

  context '#get_reservations' do
    setup do
      user = FactoryGirl.create(:user)
      @reservations = FactoryGirl.create_list(:reviewable_reservation, 2, user: user)
      @reservations_hash = { RatingConstants::HOST => user.orders.reservations, RatingConstants::GUEST => user.orders.reservations }
      @review = create(:review, rating_system: FactoryGirl.create(:rating_system, subject: RatingConstants::HOST), reviewable: @reservations.first, user: user)
      @reviews_service = ReviewsService.new(user)
    end

    should 'return reservations' do
      result = @reviews_service.get_reviewables(@reservations_hash)
      assert_equal 1, result[:seller_collection].count
      assert_equal @reservations.last, result[:seller_collection].first
    end
  end

  context '#get_transactable_type_id' do
    should 'return transactable type. reservation' do
      reservation = FactoryGirl.create(:reviewable_reservation)
      user = reservation.owner
      review = create(:review, rating_system: FactoryGirl.create(:rating_system, subject: RatingConstants::HOST), reviewable: reservation, user: user)
      params = { review: { reviewable_id: reservation.id, reviewable_type: reservation.class.name } }
      reviews_service = ReviewsService.new(user, params)
      assert_equal review.transactable_type_id, reviews_service.get_transactable_type_id
    end
  end
end
