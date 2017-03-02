# frozen_string_literal: true
# Loads the list of supported currencies, which is used by the Currency input
# and validators.
#
# We're limiting the currencies to those supported by Braintree:
# https://www.braintreepayments.com/docs/ruby/reference/currencies

DesksnearMe::Application.config.supported_currencies = []
require 'csv'

module SupportedCurrenciesHelper
  def self.get_currency_symbol_from_code(currency)
    symbol = begin
               Money::Currency.new(currency).symbol
             rescue
               currency
             end
    symbol = currency if symbol.blank?
    symbol
  end
end

CSV.foreach(Rails.root.join('config', 'supported_currencies.csv'), headers: :first_row, return_headers: false) do |row|
  DesksnearMe::Application.config.supported_currencies << {
    name: row[0],
    iso_code: row[1],
    symbol: SupportedCurrenciesHelper.get_currency_symbol_from_code(row[1])
  }
end
