require 'test_helper'

class InstanceBillingGatewayTest < ActiveSupport::TestCase
  should validate_presence_of(:currency)
  should validate_presence_of(:billing_gateway)
end
