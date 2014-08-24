class InstanceClient::StripeDecorator

  attr_accessor :instance_client

  def initialize(instance_client)
    @instance_client = instance_client
  end

  def customer_id
    response.params["id"]
  rescue
    nil
  end

  def response
    @response ||= YAML.load(instance_client.response)
  rescue
    nil
  end
end

