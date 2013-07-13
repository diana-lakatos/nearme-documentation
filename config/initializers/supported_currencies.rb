# Loads the list of supported currencies, which is used by the Currency input
# and validators.
#
# We're limiting the currencies to those supported by Braintree:
# https://www.braintreepayments.com/docs/ruby/reference/currencies

DesksnearMe::Application.config.supported_currencies = []

require 'csv'
CSV.foreach(Rails.root.join('config', 'supported_currencies.csv'), :headers => :first_row, :return_headers => false) do |row|
  DesksnearMe::Application.config.supported_currencies << {
    :name => row[0],
    :iso_code => row[1]
  }
end

