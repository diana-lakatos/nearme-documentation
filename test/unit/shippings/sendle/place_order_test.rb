# frozen_string_literal: true
require 'test_helper_lite'
require 'ostruct'
require 'active_record'
require './app/models/delivery'
require './app/models/dimensions_template'
require './app/models/deliveries/sendle'
require './app/models/deliveries/sendle/place_order'

class Deliveries::Sendle::PlaceOrderTest < ActiveSupport::TestCase
  test 'prepare required default aggregations' do
    order = OpenStruct.new(shipping_address: 1, dimensions_template: DimensionsTemplate.new)

    Deliveries::Sendle::PlaceOrder.new(Delivery.new).tag do |result|
      assert_includes result.keys, :filtered_aggregations
      assert_not_includes result.keys, :all_listings
    end
  end
end
