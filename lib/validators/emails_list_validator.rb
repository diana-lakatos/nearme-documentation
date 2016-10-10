require 'mail'
class EmailsListValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    value.split(',').each do |email|
      begin
        parsed = Mail::Address.new(email.strip)
      rescue Mail::Field::ParseError => e
      end
      parsed = nil unless parsed && parsed.domain.present?
      record.errors[attribute] << (options[:message] || 'is invalid') unless parsed
    end
  end
end
