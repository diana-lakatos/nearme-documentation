# frozen_string_literal: true
class Payment::Gateway::Response::Stripe::Account
  delegate :id, :charges_enabled, :bank_account=, :save, :default_currency, :keys, :legal_entity, :verification, to: :@response

  def initialize(response)
    @response = response
  end

  def attributes
    {
      external_id: id,
      response: to_yaml,
      fields_needed: verification.fields_needed,
      disabled_reason: localize_error(verification.disabled_reason),
      verification_message: localize_error(legal_entity.verification.details_code),
      due_by: verification.due_by,
      currency: default_currency,
      secret_key: secret_key
    }
  end

  def secret_key
    keys.secret if keys.is_a?(Stripe::StripeObject)
  end

  def verified?
    charges_enabled && payouts_enabled
  end

  def payouts_enabled
    @response.respond_to?(:payouts_enabled) ? @response.payouts_enabled : @response.try(:transfers_enabled)
  end

  def localize_error(error_code)
    return if error_code.blank?
    I18n.t('activerecord.errors.models.merchant_account.error_codes.' + error_code.tr('.', '_'))
  end
end
