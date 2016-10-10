class Billing::Gateway::Processor::Response::ResponseFactory
  def self.create(response)
    if response.include?('Paypal')
      Billing::Gateway::Processor::Response::Paypal.new(response)
    else
      Billing::Gateway::Processor::Response::Base.new(response)
    end
  end
end
