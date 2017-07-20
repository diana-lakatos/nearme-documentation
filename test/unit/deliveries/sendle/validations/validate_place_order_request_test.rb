require 'test_helper'

class Deliveries::Sendle::Validations::ValidatePlaceOrderRequestTest < ActiveSupport::TestCase

  test 'properly assign local delivery copy' do
    sender = OrderAddress.new(firstname: 'john', lastname: 'sender')
    receiver = OrderAddress.new(firstname: 'bob', lastname: 'receiver')
    record = Delivery.new(id: 100, sender_address: sender, receiver_address: receiver)

    validator = Deliveries::Sendle::Validations::ValidatePlaceOrderRequest.new(record)
    assert_nil validator.delivery.id
    assert 'john sender', validator.delivery.sender_address.full_name
    assert 'bob receiver', validator.delivery.receiver_address.full_name
    assert_not validator.delivery.persisted?
  end
end
