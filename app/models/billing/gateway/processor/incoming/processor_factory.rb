class Billing::Gateway::Processor::Incoming::ProcessorFactory

  def self.create(user, instance, currency)
    @gateway_name = begin
                      if user.country.present?
                        instance.country_instance_payment_gateways.where(country_alpha2_code: user.country.alpha2).first.try(:name)
                      else
                        instance.instance_payment_gateways.sort_by_country_support.first.try(:name)
                      end
                    end
    if @gateway_name
      processor = "Billing::Gateway::Processor::Incoming::#{@gateway_name}".constantize
      processor.new(user, instance, currency) if processor.supports_currency?(currency)
    else
      nil
    end
  end

end
