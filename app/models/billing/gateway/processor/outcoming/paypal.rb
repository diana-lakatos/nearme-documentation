class Billing::Gateway::Processor::Outcoming::Paypal < Billing::Gateway::Processor::Outcoming::Base
  include PayPal::SDK::Core::Logging

  SUPPORTED_CURRENCIES = ['USD', 'GBP', 'EUR', 'JPY', 'CAD']

  def  setup_api_on_initialize
    PayPal::SDK.configure(@instance.paypal_api_config)
    @api = PayPal::SDK::AdaptivePayments::API.new
  end

  def self.currency_supported?(currency)
    self::SUPPORTED_CURRENCIES.include?(currency)
  end

  def self.instance_supported?(instance)
    instance.paypal_supported?
  end

  def self.is_supported_by?(object)
    object.paypal_email.present?
  end

  def process_payout(amount)
    @pay = @api.build_pay({
      :actionType => "PAY",
      :currencyCode => amount.currency.iso_code,
      :feesPayer => "SENDER",
      :cancelUrl => "http://#{Rails.application.routes.default_url_options[:host]}",
      :returnUrl => "http://#{Rails.application.routes.default_url_options[:host]}",
      :receiverList => {
        :receiver => [{
          :amount => amount.to_s,
          :email => @receiver.paypal_email 
        }] 
      },
      :senderEmail => @sender.paypal_email
    })
    @pay_response = @api.pay(@pay) 
    if @pay_response.success?
      if @pay_response.paymentExecStatus == 'COMPLETED'
        payout_successful(@pay_response)
      elsif @pay_response.paymentExecStatus == 'CREATED'
        payout_pending(@pay_response)
      else
        raise "Unknown payment exec status: #{@pay_response.paymentExecStatus}"
      end
    else
      payout_failed(@pay_response.error)
    end
  end


end
