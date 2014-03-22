class Billing::Gateway::Processor::ResponseFactory

  def self.create(response)
    if response.include?('PayPal')
      Billing::Gateway::Processor::PaypalResponse.new(response)
    elsif response.include?('Balanced')
      Billing::Gateway::Processor::BalancedResponse.new(response)
    else
      Billing::Gateway::Processor::Response.new(response)
    end
  end

end
