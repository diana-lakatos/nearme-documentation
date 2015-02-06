require 'test_helper'

class ReviewsServiceTest < ActiveSupport::TestCase
  context '#get_by' do
    setup do
      @review_5_stars = FactoryGirl.create(:review, rating: '5')
      @review_3_stars = FactoryGirl.create(:review, rating: '3')
      user = @review_5_stars.user
      instance = @review_5_stars.instance
      @reviews_service = ReviewsService.new(user, instance, { rating: ['5'], date: '' })
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
      columns = *%w{id object rating user_name created_at}
      @review_1 = @reviews.first.attributes.values_at(columns).join(',')
      @review_2 = @reviews.last.attributes.values_at(columns).join(',')
      user = @reviews.first.user
      instance = @reviews.first.instance
      @reviews_service = ReviewsService.new(user, instance)
    end

    should 'return csv with reviews' do
      csv = @reviews_service.generate_csv_for(@reviews)
      assert csv.include?(@review_1)
      assert csv.include?(@review_2)
    end
  end
  
  context '#filter_period' do
    setup do
      @user = FactoryGirl.create(:user)
      @instance = FactoryGirl.create(:instance)
      @reviews_service = ReviewsService.new(@user, @instance, { rating: ['5'], date: '' })
    end

    should 'return period for 6 month' do
      reviews_service = ReviewsService.new(@user, @instance, { period: '6_months' })
      period = reviews_service.filter_period
      assert_equal 6.months.ago.to_date, period
    end

    should 'return period for 2014 year' do
      reviews_service = ReviewsService.new(@user, @instance, { period: '2014'})
      period = reviews_service.filter_period
      assert_equal [DateTime.new(2014).to_date, DateTime.new(2014).end_of_year.to_date], period
    end

    should 'return period for 2013 year' do
      reviews_service = ReviewsService.new(@user, @instance, { period: '2013'})
      period = reviews_service.filter_period
      assert_equal [DateTime.new(2013).to_date, DateTime.new(2013).end_of_year.to_date], period
    end

    should 'return period for 2012 year' do
      reviews_service = ReviewsService.new(@user, @instance, { period: '2012'})
      period = reviews_service.filter_period
      assert_equal [DateTime.new(2012).to_date, DateTime.new(2012).end_of_year.to_date], period
    end

    should 'return period for 2011 year' do
      reviews_service = ReviewsService.new(@user, @instance, { period: '2011'})
      period = reviews_service.filter_period
      assert_equal [DateTime.new(2011).to_date, DateTime.new(2011).end_of_year.to_date], period
    end

    should 'return period for 30 days without param' do
      reviews_service = ReviewsService.new(@user, @instance)
      period = reviews_service.filter_period
      assert_equal 30.days.ago.to_date, period
    end

    should 'return period for 30 days with param' do
      reviews_service = ReviewsService.new(@user, @instance, { period: '30_days' })
      period = reviews_service.filter_period
      assert_equal 30.days.ago.to_date, period
    end
  end

  context '#get_rating_systems' do
    setup do
      user = FactoryGirl.create(:user)
      instance = user.instance
      @reviews_service = ReviewsService.new(user, instance)
    end

    should 'return rating systems' do
      @rating_system = FactoryGirl.create(:active_rating_system)
      rating_systems = @reviews_service.get_rating_systems
      assert_includes rating_systems[:active_rating_systems], @rating_system
    end
  end

  context '#get_line_items_for_owner_and_creator' do
    setup do
      @order = create(:completed_order_with_totals)
      @order.update(completed_at: Date.today.yesterday)
      @line_items = @order.line_items
      user = @order.user
      instance = user.instance
      @reviews_service = ReviewsService.new(user, instance)
    end

    should 'return line items' do
      result = @reviews_service.get_line_items_for_owner_and_creator
      assert_equal result[:owner_line_items].count, @line_items.count
    end
  end

  context '#get_orders_reviews' do
    setup do
      @order = create(:completed_order_with_totals)
      @order.update(completed_at: Date.today.yesterday)
      @line_items = { owner_line_items: @order.line_items, creator_line_items: @order.line_items }
      user = @order.user
      instance = user.instance
      @review = create(:review, object: 'seller', instance: instance, reviewable: @order.line_items.first, user: user)
      @reviews_service = ReviewsService.new(user, instance)
    end

    should 'return seller reviews' do
      result = @reviews_service.get_orders_reviews(@line_items)
      assert_equal result[:seller_collection].first, @review
    end
  end

  context '#get_orders' do
    setup do
      @order = create(:completed_order_with_totals)
      @order.update(completed_at: Date.today.yesterday)
      @line_items = { owner_line_items: @order.line_items, creator_line_items: @order.line_items }
      user = @order.user
      instance = user.instance
      @review = create(:review, object: 'seller', instance: instance, reviewable: @order.line_items.first, user: user)
      @reviews_service = ReviewsService.new(user, instance)
    end

    should 'return seller line items' do
      result = @reviews_service.get_orders(@line_items)
      assert_equal result[:seller_collection].count, @order.line_items.count - 1
    end
  end

  context '#get_reservations_for_owner_and_creator' do
    setup do
      @reservation = FactoryGirl.create(:past_reservation)
      user = @reservation.creator
      instance = @reservation.instance
      @reviews_service = ReviewsService.new(user, instance)
    end

    should 'return reservations' do
      result = @reviews_service.get_reservations_for_owner_and_creator
      assert_equal result[:creator_reservations].first, @reservation
    end
  end

  context '#get_reviews_by' do
    setup do
      user = FactoryGirl.create(:user)
      @reservation = FactoryGirl.create(:past_reservation, user: user, instance: user.instance)
      instance = @reservation.instance
      @reservations = { owner_reservations: user.reservations, creator_reservations: user.reservations }
      @review = create(:review, object: 'seller', instance: instance, reviewable: @reservation, user: user)
      @reviews_service = ReviewsService.new(user, instance)
    end

    should 'return reviews' do
      result = @reviews_service.get_reviews_by(@reservations)
      assert_equal result[:seller_collection].first, @review
    end
  end

  context '#get_reservations' do
    setup do
      user = FactoryGirl.create(:user)
      @reservations = FactoryGirl.create_list(:past_reservation, 2, user: user, instance: user.instance)
      instance = user.instance
      @reservations_hash = { owner_reservations: user.reservations, creator_reservations: user.reservations }
      @review = create(:review, object: 'seller', instance: instance, reviewable: @reservations.first, user: user)
      @reviews_service = ReviewsService.new(user, instance)
    end

    should 'return reservations' do
      result = @reviews_service.get_reservations(@reservations_hash)
      assert_equal result[:seller_collection].count, 1
      assert_equal result[:seller_collection].first, @reservations.last
    end
  end

  context '#get_transactable_type_id' do
    should 'return transactable type. reservation' do
      user = FactoryGirl.create(:user)
      reservation = FactoryGirl.create(:past_reservation, user: user, instance: user.instance)
      instance = user.instance
      review = create(:review, object: 'seller', instance: instance, reviewable: reservation, user: user)
      params = { review: { reviewable_id: reservation.id, reviewable_type: reservation.class.name } }
      reviews_service = ReviewsService.new(user, instance, params)
      
      result = reviews_service.get_transactable_type_id()
      assert_equal result, review.transactable_type_id
    end

    should 'return transactable type. line item' do
      user = FactoryGirl.create(:user)
      completed_order = FactoryGirl.create(:order_with_line_items, state: 'complete', user: user)
      instance = completed_order.instance
      transactable_type_buy_sell = FactoryGirl.create(:transactable_type_buy_sell)
      line_item = completed_order.line_items.first
      review = create(:review, object: 'seller', instance: instance, reviewable: line_item, user: user)
      params = { review: { reviewable_id: line_item.id, reviewable_type: line_item.class.name } }
      reviews_service = ReviewsService.new(user, instance, params)

      result = reviews_service.get_transactable_type_id
      assert_equal result, transactable_type_buy_sell.id
    end
  end
end
