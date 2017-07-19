# frozen_string_literal: true
class ConfirmValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    matching_value = record.send(attribute.to_s.sub(/_confirmation$/, ''))
    record.errors.add(attribute, :confirmation) if matching_value.present? && matching_value != value
  end
end
