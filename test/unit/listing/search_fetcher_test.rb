require 'test_helper'

class Listing::SearchFetcherTest < ActiveSupport::TestCase

  setup do
    Transactable.destroy_all
    @public_location_type = FactoryGirl.create(:location_type, name: 'public')
    @private_location_type = FactoryGirl.create(:location_type, name: 'private')

    @public_location = FactoryGirl.create(:location, location_type: @public_location_type, location_address: FactoryGirl.build(:address, latitude: 5, longitude: 5 ))
    @private_location = FactoryGirl.create(:location, location_type: @private_location_type, location_address: FactoryGirl.build(:address, latitude: 10, longitude: 10 ))

    @public_listing_type = 'Desk'
    @private_listing_type = 'Meeting Room'
    @office_listing_type = 'Office Space'

    custom_attribute = FactoryGirl.build(:custom_attribute, :listing_types)
    TransactableType.first.custom_attributes << custom_attribute
    @public_listing = FactoryGirl.create(:transactable, properties: { listing_type: @public_listing_type }, location: @public_location)
    @public_office_listing = FactoryGirl.create(:transactable, properties: { listing_type: @office_listing_type }, location: @public_location)
    @private_listing = FactoryGirl.create(:transactable, properties: { listing_type: @private_listing_type }, location: @private_location)
    @private_office_listing = FactoryGirl.create(:transactable, properties: { listing_type: @office_listing_type }, location: @private_location)

    @public_listing_other_tt = FactoryGirl.create(:transactable, transactable_type: FactoryGirl.create(:transactable_type), properties: { listing_type: @public_listing_type }, location: @public_location)

    @free_listing = FactoryGirl.create(:free_listing)

    @filters = { midpoint: [7, 7], radius: 1000, transactable_type_id: TransactableType.first.id }
  end

  should 'return result for right transactable type' do
    assert_equal [@public_listing_other_tt], Listing::SearchFetcher.new(@filters.merge({transactable_type_id: @public_listing_other_tt.transactable_type_id}), @public_listing_other_tt.transactable_type).listings.sort
  end

  context '#geolocation' do

    should 'find locations near midpoint within given radius' do
      @filters.merge!({ midpoint: [5, 6], radius: 300 })

      assert_equal [@public_listing, @public_office_listing].sort, Listing::SearchFetcher.new(@filters, @public_listing.transactable_type).listings.sort
    end

    should 'return all locations if midpoint is missing' do
      @filters.merge!({ midpoint: nil, radius: 2 })
      assert_equal [@public_listing, @public_office_listing, @private_listing, @private_office_listing, @free_listing], Listing::SearchFetcher.new(@filters, @public_listing.transactable_type).listings.sort
    end

    should 'return all locations if radius is missing' do
      @filters.merge!({ midpoint: [1, 3], radius: nil })
      assert_equal [@public_listing, @public_office_listing, @private_listing, @private_office_listing, @free_listing], Listing::SearchFetcher.new(@filters, @public_listing.transactable_type).listings.sort
    end
  end

  context 'filters' do

    should 'find location with specified location type' do
      @filters.merge!({ location_types_ids: [@public_location_type.id] })
      assert_equal [@public_listing, @public_office_listing].sort, Listing::SearchFetcher.new(@filters, @public_listing.transactable_type).listings.sort
    end

    context '#availability' do

      should 'reject listings that are fully booked' do
        # todo
      end
    end

    context 'desk type' do

      should 'find listings that have specified desk' do
        @filters.merge!({ custom_attributes: { listing_type: [@public_listing_type, @private_listing_type] } })
        assert_equal [@public_listing, @private_listing].sort, Listing::SearchFetcher.new(@filters, @public_listing.transactable_type).listings.sort
      end

      should 'return empty array if none listing is satisfying conditions' do
        @filters.merge!({ custom_attributes: { listing_type: ["Shared Something"] } })
        assert_equal [], Listing::SearchFetcher.new(@filters, @public_listing.transactable_type).listings
      end

      should 'find listings that belong to certain location type and listing type' do
        @filters.merge!({location_types_ids: [@public_location_type.id], custom_attributes: { listing_type: [@office_listing_type] } })
        assert_equal [@public_office_listing], Listing::SearchFetcher.new(@filters, @public_listing.transactable_type).listings
      end

    end

    context 'price type' do

      should 'find listings that are free' do
        @filters.merge!({ midpoint: nil, listing_pricing: ['free'] })
        assert_equal [@free_listing], Listing::SearchFetcher.new(@filters, @public_listing.transactable_type).listings
      end

      should 'find listings that are daily' do
        @filters.merge!({ midpoint: nil, listing_pricing: ['daily'] })
        assert_equal [@public_listing, @public_office_listing, @private_listing, @private_office_listing].sort, Listing::SearchFetcher.new(@filters, @public_listing.transactable_type).listings.sort
      end

    end

    context 'company industries' do

      setup do
        @internet_industry = FactoryGirl.create(:industry, name: 'Internet')
        @economics_industry = FactoryGirl.create(:industry, name: 'Economics')
        @food_industry = FactoryGirl.create(:industry, name: 'Food')

        @internet_food_company = FactoryGirl.build(:company)
        @internet_food_company.industries = [@internet_industry, @food_industry]
        @internet_food_company.save!
        @economics_food_company = FactoryGirl.build(:company)
        @economics_food_company.industries = [@economics_industry, @food_industry]
        @economics_food_company.save!

        @location1 = FactoryGirl.create(:location, company: @internet_food_company, location_address: FactoryGirl.build(:address, latitude: 5, longitude: 5))
        @location2 = FactoryGirl.create(:location, company: @economics_food_company, location_address: FactoryGirl.build(:address, latitude: 5, longitude: 5))

        @listing1 = FactoryGirl.create(:transactable, location: @location1)
        @listing2 = FactoryGirl.create(:transactable, location: @location2)

      end

      should 'filter by single company industries' do
        @filters.merge!({industries_ids: [@economics_industry.id]})
        assert_equal [@listing2], Listing::SearchFetcher.new(@filters, @listing2.transactable_type).listings
      end

      should 'filter by multiple company industries' do
        @filters.merge!({industries_ids: [@economics_industry.id, @internet_industry.id]})
        assert_equal [@listing1, @listing2].sort, Listing::SearchFetcher.new(@filters, @listing1.transactable_type).listings.sort
      end

      should 'be able to return multiple results for single industry' do
        @filters.merge!({industries_ids: [@food_industry.id]})
        assert_equal [@listing1, @listing2].sort, Listing::SearchFetcher.new(@filters, @listing1.transactable_type).listings.sort
      end

    end

  end

end
