class PasswordValidator < ActiveModel::Validator
  def validate(record)
    validate_uppercase(record) if password_validation_rules['uppercase'] == '1'
    validate_lowercase(record) if password_validation_rules['lowercase'] == '1'
    validate_number(record) if password_validation_rules['number'] == '1'
    validate_symbol(record) if password_validation_rules['symbol'] == '1'

    record.errors[:password].uniq

    validate_length(record)
  end

  private

  def validate_uppercase(record)
    record.errors.add(:password, I18n.t('errors.messages.has_an_invalid_format')) unless record.password =~ /[A-Z]/
  end

  def validate_lowercase(record)
    record.errors.add(:password, I18n.t('errors.messages.has_an_invalid_format')) unless record.password =~ /[a-z]/
  end

  def validate_number(record)
    record.errors.add(:password, I18n.t('errors.messages.has_an_invalid_format')) unless record.password =~ /[\d]/
  end

  def validate_symbol(record)
    record.errors.add(:password, I18n.t('errors.messages.has_an_invalid_format')) unless record.password =~ /[\W_]/
  end

  def validate_length(record)
    record.errors.add(:password, I18n.t('errors.messages.too_short', count: min_length)) if record.password.size < min_length
  end

  def password_validation_rules
    PlatformContext.current.instance.password_validation_rules
  end

  def min_length
    (password_validation_rules['min_password_length'].presence || Devise.password_length.first).to_i
  end
end
