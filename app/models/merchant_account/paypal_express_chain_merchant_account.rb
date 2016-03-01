class MerchantAccount::PaypalExpressChainMerchantAccount < MerchantAccount

  SEPARATE_TEST_ACCOUNTS = true

  ATTRIBUTES = %w(email merchant_token permissions_granted consent_status
    account_status product_intent_id return_message is_email_confirmed billing_agreement_id payer_id)
  include MerchantAccount::Concerns::DataAttributes

  after_initialize :generate_merchant_token!

  def create_billing_agreement(token)
    response = payment_gateway.express_gateway.store(token)
    if response.success?
      self.billing_agreement_id = response.params["BillingAgreementID"]
      save!
    else
      false
    end
  end

  def destroy_billing_agreement
    response = payment_gateway.express_gateway.unstore(self.billing_agreement_id)
    if response.success?
      self.billing_agreement_id = nil
      save!
    else
      false
    end
  end

  def redirect_url
    chain_payments? ? payment_gateway.boarding_url(self) : super
  end

  def iso_country_code
    merchantable.try(:iso_country_code)
  end

  def chain_payment_set?
    billing_agreement_id.present?
  end

  def subject
    self.billing_agreement_id.present? ? self.payer_id : nil
  end

  def boarding_complete(response)
    self.payer_id = response["merchantIdInPayPal"]

    # Indicates whether API permissions were successfully granted from the merchant’s account to yours.
    # Possible values:
    # true (permissions were successfully granted)
    # false (permissions were not granted)
    self.permissions_granted = response["permissionsGranted"] == 'true'

    # Indicates whether the merchant consented to sharing their API credentials with you.
    # Possible values:
    # true (merchant consented to sharing their API credentials)
    # false (merchant did not consent to sharing their API credentials)
    self.consent_status = response["consentStatus"] == 'true'

    # Indicates the type of PayPal account that was created for the merchant.
    # Possible values:
    # BUSINESS_ACCOUNT (a full business account was created)
    # MINIMAL_ACCOUNT (a personal account was created)
    self.account_status = response["accountStatus"]

    # The product that the merchant was signed up for. At this time, the only possible value is addipmt.
    self.product_intent_id =  response["productIntentID"]

    # A text message, which you can display to the merchant, which indicates what they need to do next at PayPal in order to begin accepting payments.
    self.return_message = response["returnMessage"]

    # Indicates whether the merchant’s email address is confirmed at PayPal.
    self.is_email_confirmed = response["isEmailConfirmed"] == 'true'

    if self.permissions_granted && self.payer_id.present?
      self.verify
    else
      self.failure
    end
  end

  private

  def generate_merchant_token!
    self.merchant_token ||= "#{self.id}#{rand(2**32..2**64-1)}"
  end
end

