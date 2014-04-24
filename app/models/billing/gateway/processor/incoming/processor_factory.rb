class Billing::Gateway::Processor::Incoming::ProcessorFactory

  def self.create(user, instance, currency)
    return self.billing_gateway_for(instance, currency).new(user, instance, currency) if self.billing_gateway_for(instance, currency)

    if self.stripe_supported?(instance, currency)
      Billing::Gateway::Processor::Incoming::Stripe.new(user, instance, currency)
    elsif self.balanced_supported?(instance, currency)
      Billing::Gateway::Processor::Incoming::Balanced.new(user, instance, currency)
    elsif self.paypal_supported?(instance, currency)
      Billing::Gateway::Processor::Incoming::Paypal.new(user, instance, currency)
    else
      nil
    end
    
  end

  def self.billing_gateway_for(instance, currency)
    processor_name = instance.instance_billing_gateways.where(currency: currency).first
    if processor_name
      processor = "Billing::Gateway::Processor::Incoming::#{processor_name.billing_gateway.capitalize}".constantize
      processor if self.send("#{processor_name.billing_gateway.downcase}_supported?", instance, currency)
    end
  end

  def self.stripe_supported?(instance, currency)
    settings = instance.instance_payment_gateways.get_settings_for(:stripe)
    settings.present? && settings[:api_key].present? && settings[:public_key].present? && settings[:currency] == currency
  end

  def self.balanced_supported?(instance, currency)
    settings = instance.instance_payment_gateways.get_settings_for(:balanced)
    settings.present? && settings[:api_key].present? && ['USD'].include?(currency)
  end

  def self.paypal_supported?(instance, currency)
    settings = instance.instance_payment_gateways.get_settings_for(:paypal)
    settings.present? && settings[:client_id].present? && settings[:client_secret].present? && ['USD', 'GBP', 'EUR', 'JPY', 'CAD'].include?(currency)
  end
end
