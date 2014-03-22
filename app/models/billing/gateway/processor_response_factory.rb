class ProcessorResponseFactory < ActiveRecord::Base

  def self.get_response(response)
    if response.include?('PayPal')
      PaypalProcessorResponse.new(response)
    elsif response.include?('Balanced')
      BalancedProcessorResponse.new(response)
    else
      Response.new(response)
    end
  end

end
