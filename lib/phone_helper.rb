# frozen_string_literal: true
class PhoneHelper
  def initialize(number:, country:)
    @number = number
    @country = Country.educated_guess_find(country)
  end

  def country_calling_code
    return unless @country.present?

    @country.calling_code
  end

  def full_number
    return unless @number.present?
    number_with_calling_code(@number)
  end

  private

  def number_with_calling_code(number)
    calling_code = country_calling_code.present? ? "+#{country_calling_code}" : ''
    "#{calling_code}#{number.gsub(/^0/, '')}"
  end
end
