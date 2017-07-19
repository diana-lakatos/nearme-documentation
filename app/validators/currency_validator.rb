class CurrencyValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless DesksnearMe::Application.config.supported_currencies.map { |c| c[:iso_code] }.include?(value)
      record.errors[attribute] << 'Currency must be a valid ISO 4217 3-letter code'
    end
  end
end
