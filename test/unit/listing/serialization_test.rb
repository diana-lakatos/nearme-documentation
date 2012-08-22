require "test_helper"

class Listing::SerializationTest < ActiveSupport::TestCase
  context "a free listing" do
    setup do
      @listing = FactoryGirl.create(:listing, :price_cents => 0)
      @serializer = ListingSerializer.new(@listing)
    end

    should "return valid price fields" do
      json = @serializer.as_json[:listing]
      assert_equal 0, json[:price][:amount]
      assert_equal Listing::PRICE_PERIODS[:free], json[:price][:period]
    end
  end

  context "a non-free daily listing" do
    setup do
      @listing = FactoryGirl.create(:listing, :price_cents => 100_00)
      @serializer = ListingSerializer.new(@listing)
    end

    should "return valid price fields" do
      json = @serializer.as_json[:listing]
      assert_equal 100.0, json[:price][:amount]
      assert_equal Listing::PRICE_PERIODS[:day], json[:price][:period]
    end
  end

end
