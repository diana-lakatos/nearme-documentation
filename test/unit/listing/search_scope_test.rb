require 'test_helper'

class Listing::SearchScopeTest < ActiveSupport::TestCase

  context 'with geolocation stubbed' do

    setup do
      Listing::SearchScope.any_instance.stubs(:apply_geocoding).returns(true)
    end

    context 'with white label company' do
      setup do
        @company = FactoryGirl.create(:white_label_company)
      end

      context 'with locations existing' do

        setup do
          @location = FactoryGirl.create(:location, company: @company)
          @another_location = FactoryGirl.create(:location)
        end

        should 'scope to locations of this company' do
          @search_scope = Listing::SearchScope.new(white_label_company: @company)
          assert_equal [@location], @search_scope.locations
        end

        should 'scope to all locations' do
          @search_scope = Listing::SearchScope.new
          assert_equal Location.all, @search_scope.locations
        end

      end

    end

    context 'filters' do

      setup do
        @public_location_type = FactoryGirl.create(:location_type, :name => 'public')
        @private_location_type = FactoryGirl.create(:location_type, :name => 'private')
        @public_location = FactoryGirl.create(:location, :location_type => @public_location_type)
        @private_location = FactoryGirl.create(:location, :location_type => @private_location_type)
        @search_scope = Listing::SearchScope.new
      end

      should 'find location with specified location type' do
        @search_scope.filters = { :location_type_ids => [@public_location_type.id] }
        assert_equal [@public_location], @search_scope.locations
      end

      should 'find multiple locations with specified location type' do
        @search_scope.filters = { :location_type_ids => [@private_location_type.id, @public_location_type.id] }
        @result = @search_scope.locations
        assert @result.include?(@public_location) && @result.include?(@private_location)
      end

      context '#desk type' do

        setup do
          @public_listing_type = FactoryGirl.create(:listing_type, :name => 'public')
          @private_listing_type = FactoryGirl.create(:listing_type, :name => 'private')
          @public_listing = FactoryGirl.create(:listing, :listing_type => @public_listing_type, :location => @public_location)
          @private_listing = FactoryGirl.create(:listing, :listing_type => @private_listing_type, :location => @private_location)
        end

        should 'find location with at least one listing of specified desk' do
          @search_scope.filters = { :listing_type_ids => [@public_listing_type.id] }
          assert_equal [@public_location], @search_scope.locations
        end

        should 'not find location without at least one listing of specified desk' do
          @search_scope.filters = { :listing_type_ids => [FactoryGirl.create(:listing_type).id] }
          assert_equal [], @search_scope.locations
        end

        should 'not return the same location multiple times' do
          3.times do 
            FactoryGirl.create(:listing, :listing_type => @public_listing_type, :location => @public_location)
          end
          @search_scope.filters = { :listing_type_ids => [@public_listing_type.id] }
          assert_equal [@public_location], @search_scope.locations
        end

        should 'find location that at least one listing belongs to at least one type of specified listing type' do
          @search_scope.filters = { :listing_type_ids => [@public_listing_type.id, FactoryGirl.create(:listing_type, :name => 'new').id] }
          assert_equal [@public_location], @search_scope.locations
        end

      end
    end

    context 'combine white label and filters' do

      setup do
        @company = FactoryGirl.create(:white_label_company)
        @public_location_type = FactoryGirl.create(:location_type, :name => 'public')
        @private_location_type = FactoryGirl.create(:location_type, :name => 'private')
        @location = FactoryGirl.create(:location, company: @company, :location_type => @public_location_type)
        @another_location = FactoryGirl.create(:location, :location_type => @private_location_type)
      end

      should 'return locations that satisfies both filters and white label' do
        @search_scope = Listing::SearchScope.new(white_label_company: @company)
        @search_scope.filters = { :location_type_ids => [@public_location_type.id] }
        assert_equal [@location], @search_scope.locations
      end

      should 'not return locations that do not satisfy white label and filters at the same time' do
        @search_scope = Listing::SearchScope.new(white_label_company: @company)
        @search_scope.filters = { :location_type_ids => [@private_location_type.id] }
        assert_equal [], @search_scope.locations
      end

    end
  end

  context '#geolocation' do

    setup do
      @midpoint = [1,2]
      @radius = 5.0
      stub_params
      @location = FactoryGirl.create(:location, :latitude => 1, :longitude => 2)
      @another_location = FactoryGirl.create(:location, :latitude => 10, :longitude => 20)
      @search_scope = Listing::SearchScope.new
    end

    should 'find locations near midpoint within given radius' do
      @search_scope.search_params = @params
      assert_equal [@location], @search_scope.locations
    end

    should 'return no results if one of geolocation params is missing' do
      @midpoint = nil
      stub_params
      @search_scope.search_params = @params
      assert_equal [], @search_scope.locations
    end
  end

  context '#find_listings' do

    context 'with no matched location' do
      should "return empty array" do
        assert_equal [], Listing::SearchScope.new.find_listings(mock(:midpoint => nil))
      end
    end

    should "return listings scoped correctly to locations" do
      @midpoint = [1, 1]
      @radius = 2
      stub_params
      listing1 = FactoryGirl.create(:listing)
      3.times { FactoryGirl.create(:listing) }
      @search_scope = Listing::SearchScope.new
      @search_scope.stubs(:locations).returns(Location.where(:id => listing1.location).scoped)
      assert_equal [listing1], @search_scope.find_listings(@params)
    end

  end

  private
  def stub_params
    @params = mock()
    @params.stubs(:midpoint).returns(@midpoint).at_least(0)
    @params.stubs(:radius).returns(@radius).at_least(0)
    @params.stubs(:available_dates).returns([]).at_least(0)
  end
end
