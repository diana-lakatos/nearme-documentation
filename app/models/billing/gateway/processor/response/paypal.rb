class Billing::Gateway::Processor::Response::Paypal < Billing::Gateway::Processor::Response::Base
  def initialize(response)
    @response = YAML.load(response.gsub('Proc {}', ''))
  end

  def failure_message
    @response.error.first.message
  end

  attr_reader :response

  def params
    @response.params
  end

  def confirmation_url
    "https://www.paypal.com/cgi-bin/webscr?cmd=_express-checkout&token=#{@response.payKey}"
  end
end
