# frozen_string_literal: true
class PasswordRulesValidator < ActiveModel::Validator

  def validate(record)
    min_password_length = record.password_validation_rules['min_password_length']

    if min_password_length.present?
      if PasswordRulesValidator.is_numeric?(min_password_length)
        validate_min_length(record, min_password_length)
      else
        record.errors.add(:min_password_length, I18n.t('errors.messages.not_a_number'))
      end
    end
  end

  private

  def self.is_numeric?(str)
    str.present? && Float(str)
  rescue
    false
  end

  def validate_min_length(record, min_password_length)
    if min_password_length.to_i < default_min_length
      record.errors.add(:min_password_length, I18n.t('errors.messages.too_short', count: default_min_length))
    end

    if min_password_length.to_i > default_max_length
      record.errors.add(:min_password_length, I18n.t('errors.messages.too_long', count: default_max_length))
    end
  end

  def default_min_length
    Devise.password_length.first
  end

  def default_max_length
    Devise.password_length.last
  end
end
