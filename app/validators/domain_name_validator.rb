class DomainNameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors[attribute] << (options[:message] || 'is not valid.') unless value =~ /^[a-zA-Z\d\-.]{1,63}$/
   end
end
