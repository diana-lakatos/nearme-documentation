# frozen_string_literal: true
module Devise
  module Models
    # UserValidatable creates all needed validations for a user email
    # scoped by deleted_at column and password.
    # It's optional, given you may want to create the validations by yourself.
    # Automatically validate if the email is present, unique and its format is
    # valid. Also tests presence of password, confirmation and length.
    #
    # == Options
    #
    # Validatable adds the following options to devise_for:
    #
    #   * +password_length+: a range expressing password length. Defaults to 8..128.
    #
    module UserValidatable
      def self.included(base)
        base.extend ClassMethods

        base.class_eval do
          validates_presence_of :email, if: :email_required?
          validates_uniqueness_of :email, scope: [:instance_id, :external_id], allow_blank: true, if: :email_changed?
          validate :no_admin_with_such_email_exists, if: :email_changed?
          validate :no_account_hijacking_attempt, if: :email_changed?
          validates :email, email: true, if: :email_changed?

          validates_presence_of :password, if: :password_required?
          validates_confirmation_of :password, if: :password_required?

          validates_with PasswordValidator, if: proc { password.present? || password_confirmation.present? }
        end
      end

      protected

      def no_admin_with_such_email_exists
        errors.add(:email, :taken) if User.admin.where(email: email).exists?
      end

      def no_account_hijacking_attempt
        errors.add(:email, :taken) if external_id.blank? && User.where(email: email).exists?
      end

      # Checks whether a password is needed or not. For validations only.
      # Passwords are always required if it's a new record, or if the password
      # or confirmation are being set somewhere.
      def password_required?
        !persisted? || !password.nil? || !password_confirmation.nil?
      end

      def email_required?
        true
      end

      module ClassMethods
        Devise::Models.config(self, :password_length)
      end
    end
  end
end
