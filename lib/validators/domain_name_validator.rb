class DomainNameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /^[a-zA-Z\d\-.]{1,63}$/
      record.errors[attribute] << (options[:message] || 'is not valid.')
    end
   end
end
