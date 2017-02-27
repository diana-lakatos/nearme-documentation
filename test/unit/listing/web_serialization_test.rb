require 'test_helper'

class Listing::WebSerializationTest < ActiveSupport::TestCase
  context 'a listing should have all the default attributes' do
    setup do
      @listing = FactoryGirl.build(:transactable)
      @serializer = ListingWebSerializer.new(@listing)
      @json = @serializer.as_json[:listing]
    end

    should 'be serialized correctly ' do
      assert_nil @json[:id]
      assert_equal @listing.name, @json[:name]
      assert_equal @listing.description, @json[:description]
      assert_equal @listing.location_id, @json[:location_id]
      assert_equal @listing.action_type.day_pricings.first.price_cents, @json[:prices].find { |p| p[:unit] == 'day' }[:price_cents]
      assert_equal @listing.action_type.hour_pricings.first.price_cents, @json[:prices].find { |p| p[:unit] == 'hour' }[:price_cents]
      assert_equal 7, @json[:availability_rules_attributes].count
    end
  end
end
