class Billing::Gateway::Processor::Outgoing::ProcessorFactory

  def self.create(receiver, currency)
    if self.balanced_supported?(receiver.instance, currency) && self.receiver_supports_balanced?(receiver)
      Billing::Gateway::Processor::Outgoing::Balanced.new(receiver, currency)
    elsif self.paypal_supported?(receiver.instance, currency) && self.receiver_supports_paypal?(receiver)
      Billing::Gateway::Processor::Outgoing::Paypal.new(receiver, currency)
    else
      nil
    end
  end

  def self.receiver_supports_balanced?(receiver)
    receiver.instance_clients.where(:instance_id => receiver.instance.id).first.try(:balanced_user_id).present?
  end

  def self.receiver_supports_paypal?(receiver)
    receiver.paypal_email.present?
  end

  def self.support_automated_payout?(instance, currency)
    self.balanced_supported?(instance, currency) || self.paypal_supported?(instance, currency)
  end

  def self.balanced_supported?(instance, currency)
    instance.billing_gateway_credential('balanced_api_key').present? && ['USD'].include?(currency) 
  end
  
  def self.supported_payout_via_ach?(instance)
    self.balanced_supported?(instance, 'USD')
  end

  def self.paypal_supported?(instance, currency)
    instance.billing_gateway_credential('paypal_username').present? &&
    instance.billing_gateway_credential('paypal_password').present? &&
    instance.billing_gateway_credential('paypal_signature').present? &&
    instance.billing_gateway_credential('paypal_app_id').present? &&
    ['USD', 'GBP', 'EUR', 'JPY', 'CAD'].include?(currency)
  end

  private



end
