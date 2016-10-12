class PhoneNumberValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A[+]?[\d \-()]+\z/
      record.errors[attribute] << (options[:message] || 'is not valid.')
    end
  end
end
