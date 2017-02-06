# frozen_string_literal: true
class LiquidValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    Liquid::Template.parse(value, error_mode: :strict)
  rescue Liquid::SyntaxError => e
    record.errors[attribute] << "syntax is invalid (#{e.message})"
  end
end
