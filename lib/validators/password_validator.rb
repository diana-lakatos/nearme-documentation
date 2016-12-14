# frozen_string_literal: true
class PasswordValidator < ActiveModel::Validator

  attr_accessor :errors_counter, :errors_msgs

  def validate(record)
    @errors_counter = 0
    @errors_msgs = []

    validate_uppercase(record) if password_validation_rules['uppercase'] == '1'
    validate_lowercase(record) if password_validation_rules['lowercase'] == '1'
    validate_number(record) if password_validation_rules['number'] == '1'
    validate_symbol(record) if password_validation_rules['symbol'] == '1'

    validate_length(record)

    puts @errors_msgs
    record.errors.add(:password, error_full_message) if @errors_counter > 0
  end

  private

  def error_full_message
    @errors_msgs.to_sentence
  end

  def validate_uppercase(record)
    @errors_msgs << I18n.t('errors.messages.password.should_have_capital_latter')
    @errors_counter += 1 unless record.password =~ /[A-Z]/
  end

  def validate_lowercase(record)
    @errors_msgs << I18n.t('errors.messages.password.should_have_small_latter')
    @errors_counter += 1 unless record.password =~ /[a-z]/
  end

  def validate_number(record)
    @errors_msgs << I18n.t('errors.messages.password.should_have_number')
    @errors_counter += 1 unless record.password =~ /[\d]/
  end

  def validate_symbol(record)
    @errors_msgs << I18n.t('errors.messages.password.should_have_symbol')
    @errors_counter += 1 unless record.password =~ /[\W_]/
  end

  def validate_length(record)
    if record.password.size < min_length
      @errors_msgs << I18n.t('errors.messages.too_short', count: min_length)
      @errors_counter += 1
    end

    if record.password.size > max_length
      @errors_msgs << I18n.t('errors.messages.too_long', count: max_length)
      @errors_counter += 1
    end
  end

  def password_validation_rules
    PlatformContext.current.instance.password_validation_rules
  end

  def min_length
    (password_validation_rules['min_password_length'].presence || Devise.password_length.first).to_i
  end

  def max_length
    (password_validation_rules['max_password_length'].presence || Devise.password_length.last).to_i
  end
end
