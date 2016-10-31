class PhoneNumberValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors[attribute] << (options[:message] || 'is not valid.') unless value =~ /\A[+]?[\d \-()]+\z/
  end
end
