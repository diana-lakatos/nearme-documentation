require 'test_helper'

class ReviewsServiceTest < ActiveSupport::TestCase
  context '#get_by' do
    setup do
      @review_5_stars = FactoryGirl.create(:review, rating: '5')
      @review_3_stars = FactoryGirl.create(:review, rating: '3')
      @reviews_service = ReviewsService.new({ rating: ['5'], date: '' })
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
      @reviews_service = ReviewsService.new
    end

    should 'return csv with reviews' do
      csv = @reviews_service.generate_csv_for(@reviews)
      assert csv.include?(@review_1)
      assert csv.include?(@review_2)
    end
  end
  
  context '#filter_period' do
    should 'return period for 6 month' do
      reviews_service = ReviewsService.new({ period: '6_months' })
      period = reviews_service.filter_period
      assert_equal 6.months.ago.to_date, period
    end

    should 'return period for 2014 year' do
      reviews_service = ReviewsService.new({ period: '2014'})
      period = reviews_service.filter_period
      assert_equal [DateTime.new(2014).to_date, DateTime.new(2014).end_of_year.to_date], period
    end

    should 'return period for 2013 year' do
      reviews_service = ReviewsService.new({ period: '2013'})
      period = reviews_service.filter_period
      assert_equal [DateTime.new(2013).to_date, DateTime.new(2013).end_of_year.to_date], period
    end

    should 'return period for 2012 year' do
      reviews_service = ReviewsService.new({ period: '2012'})
      period = reviews_service.filter_period
      assert_equal [DateTime.new(2012).to_date, DateTime.new(2012).end_of_year.to_date], period
    end

    should 'return period for 2011 year' do
      reviews_service = ReviewsService.new({ period: '2011'})
      period = reviews_service.filter_period
      assert_equal [DateTime.new(2011).to_date, DateTime.new(2011).end_of_year.to_date], period
    end

    should 'return period for 30 days without param' do
      reviews_service = ReviewsService.new({})
      period = reviews_service.filter_period
      assert_equal 30.days.ago.to_date, period
    end

    should 'return period for 30 days with param' do
      reviews_service = ReviewsService.new({ period: '30_days' })
      period = reviews_service.filter_period
      assert_equal 30.days.ago.to_date, period
    end
  end
end
