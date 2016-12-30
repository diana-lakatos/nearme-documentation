class PaymentGateway::PaypalExpressChainPaymentGateway < PaymentGateway
  include ActionView::Helpers::SanitizeHelper
  include PaymentExtention::PaypalMerchantBoarding
  include PaymentExtention::PaypalExpressModule

  supported :paypal_chain_payments, :multiple_currency, :express_checkout_payment, :immediate_payout,
            :partial_refunds, :refund_from_host

  def self.active_merchant_class
    ActiveMerchant::Billing::PaypalExpressGateway
  end

  def self.supported_countries
    all_supported_by_pay_pal - %w(BR IN IL JP)
  end

  def self.settings
    {
      login: { validate: [:presence], change: [:void_merchant_accounts] },
      password: { validate: [:presence] },
      signature: { validate: [:presence] },
      partner_id: { validate: [:presence], change: [:void_merchant_accounts] }
    }
  end

  def settings_hash
    {
      login: settings[:login],
      password: settings[:password],
      signature: settings[:signature],
      subject: subject,
      test: test_mode?
    }
  end

  def immediate_payout(company)
    merchant_account(company).present? && merchant_account(company).subject.present?
  end

  def process_payout(merchant_account, _amount, reference)
    reference_id = merchant_account.try(:billing_agreement_id)
    response = if reference.total_service_fee.cents > 0
                 gateway.reference_transaction(reference.total_service_fee.cents, reference_id: reference_id)
               else
                 OpenStruct.new(success: true, success?: true, refunded_ammount: reference.total_service_fee.cents)
    end

    if response.success?
      payout_successful(response)
    else
      payout_failed(response)
    end
  end

  def gateway_refund(amount, token, options)
    gateway(@payment.payable.merchant_subject).refund(amount, token, options)
  rescue => e
    OpenStruct.new(success?: false, message: e.to_s)
  end

  def express_gateway(merchant_account_id=nil)
    gateway(merchant_account_id || @order.try(:merchant_subject))
  end

  def set_billing_agreement(options)
    @response = gateway.setup_authorization(0, options.deep_merge(billing_agreement: {
                                                                    type: 'MerchantInitiatedBilling',
                                                                    description: "#{PlatformContext.current.instance.name} Billing Agreement"
                                                                  }))
  end
end
