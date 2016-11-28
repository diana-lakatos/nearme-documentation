# frozen_string_literal: true
class UserVerificationForm < BaseForm
  property :token, virtual: true
  property :verified_at, virtual: true

  validate :token do
    errors.add(:token, :blank) if token.blank?
    errors.add(:token, :invalid) if token_invalid?
    errors.add(:token, :already_verified) if verified_at.present?
  end

  def email_verification_token
    Digest::SHA1.hexdigest(
      "--dnm-token-#{model.id}-#{model.created_at.utc.strftime('%Y-%m-%d %H:%M:%S')}"
    )
  end

  def sync
    super
    model.verified_at = Time.zone.now
  end

  protected

  def token_invalid?
    email_verification_token != token
  end
end
