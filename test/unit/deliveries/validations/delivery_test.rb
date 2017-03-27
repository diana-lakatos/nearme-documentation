require 'test_helper_lite'
require 'active_model'
require './app/models/deliveries/validations/delivery'
require './app/models/deliveries/validations'
require './app/models/deliveries/sendle/validations/delivery'
require 'pry'
require 'date'

class Deliveries::Validations::DeliveryTest < ActiveSupport::TestCase
  def validator
    Deliveries::Validations::Delivery.new
  end

  test 'default validations' do
    assert_nothing_raised do
      validator.validator_for(nil)
    end
  end

  test 'sendle validations' do
    assert_nothing_raised do
      validator.validator_for('sendle')
    end
  end
end
