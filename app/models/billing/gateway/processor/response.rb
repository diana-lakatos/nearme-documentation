class Billing::Gateway::Processor::Response

  def initialize(response)
    @response = response
  end

  def failure_message
  end

  def verify_after_time_arguments
    nil
  end

  def should_be_verified_after_time?
    false
  end

  def confirmation_url
    nil
  end

  def to_yaml
    @response.to_yaml
  end

end
