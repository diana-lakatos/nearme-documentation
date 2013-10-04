require 'test_helper'

class LocationTest < ActiveSupport::TestCase

  subject do
    @location = FactoryGirl.create(:location)
  end

  should belong_to(:company)
  should belong_to(:location_type)
  should have_many(:listings)

  should validate_presence_of(:company)
  should validate_presence_of(:description)
  should validate_presence_of(:address)
  should validate_presence_of(:latitude)
  should validate_presence_of(:longitude)
  should validate_presence_of(:location_type_id)
  should_not allow_value('not_an_email').for(:email)
  should allow_value('an_email@domain.com').for(:email)

  should_not allow_value('xxx').for(:currency)
  should allow_value('USD').for(:currency)

  should allow_value('x' * 250).for(:description)
  should_not allow_value('x' * 251).for(:description)

  should "be valid even if its listing is not valid" do
    @location = FactoryGirl.create(:location)
    @listing = FactoryGirl.create(:listing, :location => @location)
    @listing.name = nil
    @listing.save(:validate => false)
    @location.reload
    assert @location.valid?
  end

  context "#name" do

    setup do
      @location = FactoryGirl.create(:location_in_san_francisco)
      @location.company.name = 'This is company name'
    end
    should "use combination of company name and street if available" do
      @location.street = 'Street'
      @location.company.save!
      @location.company.reload
      assert_equal "This is company name @ Street", @location.name
    end

    should "use combination of company name and part of address if available" do
      @location.street = nil
      @location.address = 'Street, City, Country'
      @location.company.save!
      @location.company.reload
      assert_equal "This is company name @ Street", @location.name
    end

  end

  context "#description" do
    context "when not set" do
      context "and there is not a listing for the location" do
        should "return an empty string" do
          location = Location.new
          assert_equal "", location.description
        end
      end
      context "and there is a listing with a description" do
        should "return the first listings description" do
          location = Location.new
          listing = Listing.new(description: "listing description")
          location.listings << listing
          assert_equal "listing description", location.description
        end
      end
    end
  end
  context "availability" do
    should "return an Availability::Summary for the Location's availability rules" do
      location = Location.new
      location.availability_rules << AvailabilityRule.new(:day => 0, :open_hour => 6, :open_minute => 0, :close_hour => 20, :close_minute => 0)

      assert location.availability.is_a?(AvailabilityRule::Summary)
      assert location.availability.open_on?(:day => 0, :hour => 6)
      assert !location.availability.open_on?(:day => 1)
    end

    should "return an Array of full week availability ordered by day" do
      location = Location.new
      location.availability_rules << AvailabilityRule.new(:day => 0, :open_hour => 6, :open_minute => 0, :close_hour => 20, :close_minute => 0)
      location.availability_rules << AvailabilityRule.new(:day => 2, :open_hour => 6, :open_minute => 0, :close_hour => 20, :close_minute => 0)
      availability_all = location.availability.full_week
      assert availability_all.is_a?(Array)
      assert_equal availability_all.count, 7
      assert_equal availability_all[0][:day], 1
      assert_equal availability_all[1][:day], 2
      assert_equal availability_all[1][:rule].id, nil
      assert_equal availability_all[2][:rule].day, 3
      assert_equal availability_all[6][:rule].day, 0
    end

  end

  context "friendly url" do
    should 'store slug in the database' do
      @location = FactoryGirl.build(:location_in_san_francisco, :formatted_address => 'San Francisco, CA, California, USA')
      @location.save!
      @location.reload
      assert_equal "san-francisco-ca-california-usa", @location.slug
    end

    should 'update slug along with formatted_address ' do
      @location = FactoryGirl.create(:location_in_san_francisco, :formatted_address => 'Ursynowska, warsaw, Poland')
      assert_equal "ursynowska-warsaw-poland", @location.slug
      @location.formatted_address = 'San Francisco, CA, California, USA'
      @location.save!
      assert_equal "san-francisco-ca-california-usa", @location.slug
    end

  end

  context "geolocate ourselves" do

    def setup
      @location = FactoryGirl.create(:location_in_san_francisco)
    end

    should "not be valid if cannot geolocate" do
      stub_request(:get, "http://maps.googleapis.com/maps/api/geocode/json?address=this%20does%20not%20exists%20at%20all&language=en&sensor=false").to_return(:status => 200, :body => "{}", :headers => {})
      @location.address = "this does not exists at all"
      @location.save
      assert @location.errors.include?(:latitude)
    end

  end


  context "creating address components" do

    setup do
      @location = FactoryGirl.create(:location_ursynowska_address_components)
    end

    context 'creates address components for new record' do

      should "store address components" do
        assert_equal(8, @location.address_components.count)
      end

      should "be able to get city, suburb, state, country and postal code" do
        assert_equal 'Ursynowska', @location.street
        assert_equal 'Warsaw', @location.city
        assert_equal 'Mokotow', @location.suburb
        assert_equal 'Masovian Voivodeship', @location.state
        assert_equal 'Poland', @location.country
        assert_equal '02-690', @location.postcode
      end

      should "ignore missing fields and store the one present" do
        @location = FactoryGirl.create(:location_warsaw_address_components)
        assert_equal 'Warsaw', @location.city
        assert_equal nil, @location.suburb
      end

    end

    should "handle trash" do
      @location.address_components = { 0 => { "does" => "not", "exist" => ", but", "should" => "work"} }
      @location.save!
      @location.reload
      assert_equal nil, @location.city
    end

    should "should update all address components fields based on address_components" do
      @location.attributes = FactoryGirl.attributes_for(:location_san_francisco_address_components)
      assert_not_equal "San Francisco", @location.city
      @location.parse_address_components
      assert_equal "San Francisco", @location.city
      assert_equal "California", @location.state
      assert_equal "United States", @location.country
      assert_equal nil, @location.suburb
      assert_equal "San Francisco", @location.street # this is first part of address
    end
  end

end
