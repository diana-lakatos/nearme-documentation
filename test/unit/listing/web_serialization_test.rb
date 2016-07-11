require "test_helper"

class Listing::WebSerializationTest < ActiveSupport::TestCase
  context "a listing should have all the default attributes" do
    setup do
      @listing = FactoryGirl.build(:transactable)
      @serializer = ListingWebSerializer.new(@listing)
      @json = @serializer.as_json[:listing]
    end

    should "have an id" do
      assert_equal @listing.id, @json[:id]
    end

    should "have an name" do
      assert_equal @listing.name, @json[:name]
    end

    should "have an description" do
      assert_equal @listing.description, @json[:description]
    end

    should "have a location_id" do
      assert_equal @listing.location_id, @json[:location_id]
    end

    should "have a listing_type_id" do
      assert_equal @listing.listing_type_id, @json[:listing_type_id]
    end

    should "have a daily price" do
      assert_equal @listing.action_type.day_pricings.first.price_cents, @json[:prices].find{|p| p[:unit] == 'day' }[:price_cents]
    end

    should "have a hourly price" do
      assert_equal @listing.action_type.hour_pricings.first.price_cents, @json[:prices].find{|p| p[:unit] == 'hour' }[:price_cents]
    end

    should "have 7 availability rules defined" do
      assert_equal 7, @json[:availability_rules_attributes].count
    end

    should "have amenity_ids" do
      assert @json[:amenity_ids].empty?
    end

  end

 end

