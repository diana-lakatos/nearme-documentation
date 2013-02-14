require "test_helper"

class Listing::WebSerializationTest < ActiveSupport::TestCase
  context "a listing should have all the default attributes" do
    setup do
      @listing = FactoryGirl.create(:listing)
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

    should "have a defer_availabity_rules flag" do
      assert_equal 1, @json[:defer_availability_rules]
    end

    should "have a daily_price" do
      assert_equal @listing.daily_price, @json[:daily_price]
    end

    should "have a weekly_price" do
      assert_equal @listing.weekly_price, @json[:weekly_price]
    end

    should "have a monthly_price" do
      assert_equal @listing.monthly_price, @json[:monthly_price]
    end

    should "have an availability_template_id" do
      assert @json[:availability_template_id].empty?
    end

    should "have 7 availability rules defined" do
      assert_equal 7, @json[:availability_rules_attributes].count
    end

  end

 end

