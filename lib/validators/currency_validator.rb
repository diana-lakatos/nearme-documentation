class CurrencyValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless Money::Currency.table.to_a.map { |c| c[1][:iso_code] }.include?(value)
      record.errors[attribute] << 'Currency must be a valid ISO 4217 3-letter code'
    end
  end
end
