require "test_helper"

class Listing::SerializationTest < ActiveSupport::TestCase
  context "a free listing" do
    setup do
      @listing = FactoryGirl.build(:transactable)
      @serializer = ListingSerializer.new(@listing)
    end

    should "have pricings" do
      json = @serializer.as_json[:listing]
      assert json[:prices].present?
      assert json[:prices].many?
      assert_equal @listing.action_type.pricings.size, json[:prices].count
      assert_equal @listing.action_type.hour_pricings[0].price_cents, json[:prices].find{|p| p[:unit] == 'hour'}[:price_cents]
    end
  end
end
