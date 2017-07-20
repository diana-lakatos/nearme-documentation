require 'test_helper_lite'
require 'bundler'
require 'active_model'
require './app/models/deliveries/validations'
require './app/models/deliveries/request_logger'
require './app/models/deliveries/sendle/commands/place_order'
require './app/models/deliveries/sendle/validations/delivery'
require './app/models/deliveries/sendle/validations/pickup_business_date_validator'
require 'date'

class MyOrderAddress
end

class MyDelivery
  include ActiveModel::Validations

  attr_accessor :pickup_date
  attr_accessor :courier
  attr_accessor :sender_address, :receiver_address
end


class MyValidationDelivery < Deliveries::Sendle::Validations::Delivery
  def validator_list
    [
      presence_validator(attributes: [:pickup_date, :sender_address, :receiver_address]),
      pickup_busines_date_validator(attributes: [:pickup_date])
    ]
  end
end

class Deliveries::Sendle::Validations::DeliveryTest < ActiveSupport::TestCase
  def validator
    MyValidationDelivery.new
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

    assert delivery.errors.added?(:pickup_date, :non_business_day)
  end
end
