class Billing::Gateway::Processor::Response::Paypal < Billing::Gateway::Processor::Response::Base

  def initialize(response)
    @response = YAML.load(self.response.gsub('Proc {}', ''))
  end

  def failure_message
    @response.first.message
  end

  def confirmation_url
    "https://www.paypal.com/cgi-bin/webscr?cmd=_express-checkout&token=#{@response.payKey}"
  end

end
