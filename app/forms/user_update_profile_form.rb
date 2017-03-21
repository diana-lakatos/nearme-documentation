# frozen_string_literal: true
class UserUpdateProfileForm < UserForm
  property :password_confirmation, virtual: true
  validate :password_confirmation_matches?, if: -> { password.present? }

  def password_confirmation_matches?
    errors.add(:password_confirmation, :confirmation) if password != password_confirmation
  end
end
