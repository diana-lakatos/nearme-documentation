require 'test_helper'

class LocationTest < ActiveSupport::TestCase

  should belong_to(:company)
  should have_many(:listings)

  should validate_presence_of(:company_id)
  should validate_presence_of(:name)
  should validate_presence_of(:description)
  should validate_presence_of(:address)
  should validate_presence_of(:latitude)
  should validate_presence_of(:longitude)
  should_not allow_value('not_an_email').for(:email)
  should allow_value('an_email@domain.com').for(:email)

  should_not allow_value('xxx').for(:currency)
  should allow_value('USD').for(:currency)

  should allow_value('x' * 250).for(:description)
  should_not allow_value('x' * 251).for(:description)

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
  end

  context "creating address components" do

    setup do
      @user = FactoryGirl.create(:user)
      @company = FactoryGirl.create(:company_in_auckland, :creator_id => @user.id)
      @location = FactoryGirl.build(:location_in_auckland)
      @company.locations << @location
      @location.address_components_hash = get_params_for_address_components
    end

    context 'formatted address has not changed ' do


      should "not create address components" do
        @location.save!
        @location.phone = "000 0000 000"
        @location.build_address_components_if_necessary
        assert_equal(0, @location.address_component_names.count)
      end

    end

    context 'formatted address has changed' do

      should "create address components" do
        @location.save!
        @location.formatted_address = "Ursynowska, Warszawa, Poland"
        @location.build_address_components_if_necessary
        assert_equal(6, @location.address_component_names.count)
      end

    end

    context 'is new record' do

      should " create address components" do
        @location.build_address_components
        assert_equal(6, @location.address_component_names.count)
      end

    end
  end

  private

  def get_params_for_address_components
    # real data from google geocoder
    {
      "0"=> {
      "long_name"=>"Ursynowska", 
      "short_name"=>"Ursynowska", 
      "types"=>"route"
    }, 
      "1"=>{
      "long_name"=>"Mokotow", 
      "short_name"=>"Mokotow", 
      "types"=>"sublocality,political"
    }, 
      "2"=>{
      "long_name"=>"Warsaw", 
      "short_name"=>"Warsaw", 
      "types"=>"locality,political"
    },
      "3"=>{
      "long_name"=> "Warszawa", 
      "short_name"=>"Warszawa", 
      "types"=>"administrative_area_level_3,political"
    }, 
      "4"=>{
      "long_name"=>"Warszawa", 
      "short_name"=>"Warszawa", 
      "types"=>"administrative_area_level_2,political"
    }, 
      "5"=>{
      "long_name"=>"Masovian Voivodeship", 
      "short_name"=>"Masovian Voivodeship", 
      "types"=>"administrative_area_level_1,political"
    }, 
      "6"=>{
      "long_name"=>"Poland", 
      "short_name"=>"PL", 
      "types"=>"country,political"
    }
    }
  end end
