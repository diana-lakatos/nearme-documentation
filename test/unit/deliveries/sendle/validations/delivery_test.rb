require 'test_helper_lite'
require 'active_model'
# require './app/models/deliveries'
require './app/models/deliveries/validations'
require './app/models/deliveries/sendle/validations/delivery'
require 'date'

class MyOrderAddress
end

class MyDelivery
  include ActiveModel::Validations

  attr_accessor :pickup_date
  attr_accessor :courier
  attr_accessor :sender_address, :receiver_address
end

class Deliveries::Sendle::Validations::DeliveryTest < ActiveSupport::TestCase
  def validator
    Deliveries::Sendle::Validations::Delivery.new
  end

  test 'general validations' do
    delivery = MyDelivery.new

    validator.validate(delivery)

    assert delivery.errors.added?(:pickup_date, :blank)
    assert delivery.errors.added?(:sender_address, :blank)
    assert delivery.errors.added?(:receiver_address, :blank)
  end

  test 'all good' do
    delivery = MyDelivery.new
    delivery.pickup_date = Date.parse('2016-11-16')
    delivery.sender_address = MyOrderAddress.new
    delivery.receiver_address = MyOrderAddress.new

    validator.validate(delivery)

    assert_equal delivery.errors.messages, {}
  end

  test 'business days only validations' do
    delivery = MyDelivery.new
    delivery.pickup_date = Date.parse('2016-11-13')

    validator.validate(delivery)

    assert delivery.errors.added?(:pickup_date, :pick_up_only_on_business_days)
  end
end
