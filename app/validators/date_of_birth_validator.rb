# frozen_string_literal: true
class DateOfBirthValidator < ActiveModel::EachValidator
  DEFAULT_FORMAT = '%Y-%m-%d'
  def validate_each(record, attribute, value)
    return if value.blank?
    begin
      parsed = Date.strptime(value, date_format)
    rescue ArgumentError => _
    end
    record.errors[attribute] << (options[:message] || 'is invalid') unless parsed
  end

  private

  def date_format
    I18n.t('date.formats.stripe') || DEFAULT_FORMAT
  end
end
