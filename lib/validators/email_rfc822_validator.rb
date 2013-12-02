require 'mail'
class EmailRfc822Validator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    begin
      parsed = Mail::Address.new(value)
    rescue Mail::Field::ParseError => e
    end
    record.errors[attribute] << (options[:message] || "is invalid") unless parsed
  end
end
