require 'mail'
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    begin
      parsed = Mail::Address.new(value)
    rescue Mail::Field::ParseError => e
    end

    parsed = nil unless parsed && parsed.domain.present?

    record.errors[attribute] << (options[:message] || 'is invalid') unless parsed
  end
end
