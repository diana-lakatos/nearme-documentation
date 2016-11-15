# frozen_string_literal: true
require 'test_helper_lite'
require 'ostruct'
require 'active_record'
require './app/models/shippings/order.rb'

class Shippings::DeliveryFactoryTest < ActiveSupport::TestCase
  test 'prepare required default aggregations' do
    order = OpenStruct.new(shipping_address: 1)

    Shippings::DeliveryFactory.create(order: order).tag do |result|
      assert_includes result.keys, :filtered_aggregations
      assert_not_includes result.keys, :all_listings
    end
  end
end
