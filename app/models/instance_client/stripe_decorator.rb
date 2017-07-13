require 'stripe'

class InstanceClient::StripeDecorator
  attr_accessor :instance_client

  def initialize(instance_client)
    @instance_client = instance_client
  end

  def customer_id
    response.try(:id) || response.params['id']
  rescue
    nil
  end

  def response
    @response ||= YAML.load(instance_client.response)
  rescue
    nil
  end

  def find
    @instance_client.payment_gateway.find_customer(customer_id)
  end

  def test_mode?
    !response.params['livemode']
  rescue
    true
  end
end
