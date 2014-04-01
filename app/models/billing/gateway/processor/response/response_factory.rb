class Billing::Gateway::Processor::Response::ResponseFactory

  def self.create(response)
    if response.include?('PayPal')
      Billing::Gateway::Processor::Response::Paypal.new(response)
    elsif response.include?('Balanced')
      Billing::Gateway::Processor::Response::Balanced.new(response)
    else
      Billing::Gateway::Processor::Response::Base.new(response)
    end
  end

end
