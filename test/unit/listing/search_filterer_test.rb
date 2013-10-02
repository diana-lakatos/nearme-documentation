require 'test_helper'

class Listing::SearchScopeTest < ActiveSupport::TestCase

  setup do
    @search_scope = Location.scoped

    @public_location_type = FactoryGirl.create(:location_type, :name => 'public')
    @private_location_type = FactoryGirl.create(:location_type, :name => 'private')

    @public_location = FactoryGirl.create(:location, :location_type => @public_location_type, :latitude => 5, :longitude => 5)
    @private_location = FactoryGirl.create(:location, :location_type => @private_location_type, :latitude => 10, :longitude => 10)

    @public_listing_type = FactoryGirl.create(:listing_type, :name => 'public')
    @private_listing_type = FactoryGirl.create(:listing_type, :name => 'private')
    @office_listing_type = FactoryGirl.create(:listing_type, :name => 'office')

    @public_listing = FactoryGirl.create(:listing, :listing_type => @public_listing_type, :location => @public_location)
    @public_office_listing = FactoryGirl.create(:listing, :listing_type => @office_listing_type, :location => @public_location)
    @private_listing = FactoryGirl.create(:listing, :listing_type => @private_listing_type, :location => @private_location)
    @private_office_listing = FactoryGirl.create(:listing, :listing_type => @office_listing_type, :location => @private_location)

    @filters = { :midpoint => [7, 7], :radius => 1000 }
  end

  context '#geolocation' do

    should 'find locations near midpoint within given radius' do
      @filters = { :midpoint => [5, 6], :radius => 300 }
      assert_equal [@public_listing, @public_office_listing].sort, Listing::SearchFilterer.new(@search_scope, @filters).find_listings.sort
    end

    should 'return no results if midpoint is missing' do
      @filters = { :midpoint => nil, :radius => 2 }
      assert_equal [], Listing::SearchFilterer.new(@search_scope, @filters).find_listings
    end

    should 'return no results if radius is missing' do
      @filters = { :midpoint => [1, 3], :radius => nil }
      assert_equal [], Listing::SearchFilterer.new(@search_scope, @filters).find_listings
    end
  end

  context '#using scope' do

    should "return listings scoped correctly" do
      @search_scope = Location.where(:id => @public_listing.location.id).scoped
      assert_equal [@public_listing, @public_office_listing].sort, Listing::SearchFilterer.new(@search_scope, @filters).find_listings.sort
    end

  end

  context 'filters' do

    should 'find location with specified location type' do
      @filters.merge!({ :location_types_ids => [@public_location_type.id] })
      assert_equal [@public_listing, @public_office_listing].sort, Listing::SearchFilterer.new(@search_scope, @filters).find_listings.sort
    end

    context '#availability' do

      should 'reject listings that are fully booked' do
        # todo
      end
    end

    context '#desk type' do

      should 'find listings that have specified desk' do
        @filters.merge!({ :listing_types_ids => [@public_listing_type.id, @private_listing_type.id] })
        assert_equal [@public_listing, @private_listing].sort, Listing::SearchFilterer.new(@search_scope, @filters).find_listings.sort
      end

      should 'return empty array if none listing is satisfying conditions' do
        @filters.merge!({ :listing_types_ids => [FactoryGirl.create(:listing_type).id] })
        assert_equal [], Listing::SearchFilterer.new(@search_scope, @filters).find_listings
      end

      should 'find listings that belong to certain location type and listing type' do
        @filters.merge!({:location_types_ids => [@public_location_type.id], :listing_types_ids => [@office_listing_type.id] })
        assert_equal [@public_office_listing], Listing::SearchFilterer.new(@search_scope, @filters).find_listings
      end

    end

    context 'company industries' do

      setup do
        @internet_industry = FactoryGirl.create(:industry, :name => 'Internet')
        @economics_industry = FactoryGirl.create(:industry, :name => 'Economics')
        @food_industry = FactoryGirl.create(:industry, :name => 'Food')

        @internet_food_company = FactoryGirl.build(:company)
        @internet_food_company.industries = [@internet_industry, @food_industry]
        @internet_food_company.save!
        @economics_food_company = FactoryGirl.build(:company)
        @economics_food_company.industries = [@economics_industry, @food_industry]
        @economics_food_company.save!

        @location1 = FactoryGirl.create(:location, :company => @internet_food_company, :latitude => 5, :longitude => 5)
        @location2 = FactoryGirl.create(:location, :company => @economics_food_company, :latitude => 5, :longitude => 5)
        @filters = { :midpoint => [7, 7], :radius => 1000 }

        @listing1 = FactoryGirl.create(:listing, :location => @location1)
        @listing2 = FactoryGirl.create(:listing, :location => @location2)
      end

      should 'filter by single company industries' do
        @filters.merge!({:industries_ids => [@economics_industry.id]})
        assert_equal [@listing2], Listing::SearchFilterer.new(@search_scope, @filters).find_listings
      end

      should 'filter by multiple company industries' do
        @filters.merge!({:industries_ids => [@economics_industry.id, @internet_industry.id]})
        assert_equal [@listing1, @listing2].sort, Listing::SearchFilterer.new(@search_scope, @filters).find_listings.sort
      end

      should 'be able to return multiple results for single industry' do
        @filters.merge!({:industries_ids => [@food_industry.id]})
        assert_equal [@listing1, @listing2].sort, Listing::SearchFilterer.new(@search_scope, @filters).find_listings.sort
      end

    end

  end

end
