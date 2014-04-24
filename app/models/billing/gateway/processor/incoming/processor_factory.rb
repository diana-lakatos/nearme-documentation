class Billing::Gateway::Processor::Incoming::ProcessorFactory

  def self.create(user, instance, currency)
    if user.country.present?
      country_payment_gateway = instance.country_instance_payment_gateways.where(country_alpha2_code: user.country.alpha2).first
      
      if country_payment_gateway.present?
        @gateway_name = country_payment_gateway.name
      else
        return nil
      end
    else
      instance_payment_gateway = instance.instance_payment_gateways.sort_by_country_support.first
      @gateway_name = instance_payment_gateway.name
    end

    processor = "Billing::Gateway::Processor::Incoming::#{@gateway_name}".constantize
    processor.new(user, instance, currency) if processor.supports_currency?(currency)
  end

end
