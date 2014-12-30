class Billing::Gateway::Processor::Incoming::ProcessorFactory

  def self.create(user, instance, currency, country_alpha_2)
    if country_alpha_2.present?
      @gateway_name = instance.country_instance_payment_gateways.where(country_alpha2_code: country_alpha_2).first.try(:name)
    end
    if @gateway_name
      processor = "Billing::Gateway::Processor::Incoming::#{@gateway_name}".constantize
      processor.new(user, instance, currency) if processor.supports_currency?(currency)
    else
      nil
    end
  end

end
