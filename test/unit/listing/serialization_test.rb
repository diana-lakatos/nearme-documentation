require "test_helper"

class Listing::SerializationTest < ActiveSupport::TestCase
  context "a free listing" do
    setup do
      @listing = FactoryGirl.create(:free_listing)
      @serializer = ListingSerializer.new(@listing)
    end

    should "return valid price fields" do
      json = @serializer.as_json[:listing]
      assert_equal 0, json[:price][:amount]
      assert_equal Listing::PRICE_PERIODS[:free], json[:price][:period]
      assert_equal "Free", json[:price][:label]
    end
  end

  context "a non-free daily listing" do
    setup do
      @listing = FactoryGirl.create(:hundred_dollar_listing)
      @serializer = ListingSerializer.new(@listing)
    end

    should "return valid price fields" do
      json = @serializer.as_json[:listing]
      assert_equal 100.0, json[:price][:amount]
      assert_equal Listing::PRICE_PERIODS[:day], json[:price][:period]
      assert_equal "$100.00", json[:price][:label]
    end
  end

  context "a 'Call' daily listing" do
    setup do
      @listing = FactoryGirl.create(:call_listing)
      @serializer = ListingSerializer.new(@listing)
      @json = @serializer.as_json[:listing]
    end

    should "be labeled as 'Call'" do
      assert_equal "Call", @json[:price][:label]
    end
  end

end
