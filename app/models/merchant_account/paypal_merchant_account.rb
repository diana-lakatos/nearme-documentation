class MerchantAccount::PaypalMerchantAccount < MerchantAccount

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

  def chain_payments?
    payment_gateway.supports_paypal_chain_payments?
  end

  def chain_payment_set?
    billing_agreement_id.present?
  end

  def subject
    self.billing_agreement_id.present? ? self.payer_id : nil
  end

  # def setup_rest_api
  #   require 'paypal-sdk-rest'

  #   PayPal::SDK.configure(
  #     :mode => "sandbox",
  #     :client_id => "ATohC66_bMAvdXGPVCRO36Nm5GOW-2mkyrIzfuw1gzF0nR7Dcj2IUE-urKoLGefxLDaryhhL_rN0wwGN",
  #     :client_secret => "EH2Ww2WwJScL8wJA8EkKIW56FH3h0vEwbCxT6poMb4vkFQ2R9RLcDnDqUMaHaJP791vOd63h8wgrDhv1",
  #     :openid_redirect_uri  => "https://erosy.localtunnel.me",
  #     :ssl_options => { }
  #   )

  #   include PayPal::SDK::OpenIDConnect

  #   rest = PayPal::SDK::Core::API::REST.new
  #   token = rest.token

  #   path = "v1/customer/partners/GYNF63X9QS4D8/merchant-integrations"
  #   options = { tracking_id: 169439463323667316512 }

  #   rest.get(path, options)

  #   PayPal::SDK::REST.set_config(
  #     :mode => "sandbox", # "sandbox" or "live"
  #     :client_id => "ATohC66_bMAvdXGPVCRO36Nm5GOW-2mkyrIzfuw1gzF0nR7Dcj2IUE-urKoLGefxLDaryhhL_rN0wwGN",
  #     :client_secret => "EH2Ww2WwJScL8wJA8EkKIW56FH3h0vEwbCxT6poMb4vkFQ2R9RLcDnDqUMaHaJP791vOd63h8wgrDhv1",
  #     :openid_redirect_uri  =>"https://erosy.localtunnel.me")
  # end

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
    # isEmailConfirmed
    # Indicates whether the merchant’s email address is confirmed at PayPal.
    # Possible values:
    # true (email address is confirmed)
    # false (email address is not confirmed)
    self.product_intent_id =  response["productIntentID"]

    # A text message, which you can display to the merchant, which indicates what they need to do next at PayPal in order to begin accepting payments.
    self.return_message = response["returnMessage"]
    self.is_email_confirmed = response["isEmailConfirmed"]

    if self.permissions_granted && self.payer_id.present?
      self.verify
    else
      self.fail
    end
  end

  private

  def generate_merchant_token!
     self.merchant_token ||= "#{self.id}#{rand(2**32..2**64-1)}"
  end
end

