class Billing::Gateway::Processor::BalancedResponse < Billing::Gateway::Processor::Response

  def initialize(response)
    @response = YAML.load(response)
  end

  def failure_message
    @response.body["description"].split('Your request id')[0]
  end

  def should_be_verified_after_time?
    true
  end

  def verify_after_time_arguments
    @response.attributes["uri"]
  end

end
