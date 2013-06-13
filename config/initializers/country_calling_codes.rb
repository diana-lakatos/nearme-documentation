# Loads the country calling code csv database
# Maps the codes as a hash of Country Name => Calling Code
# Downloaded from: http://www.aggdata.com/free/international-calling-codes

require 'csv'
codes = []
CSV.foreach(Rails.root.join(*%w(config country_calling_codes.csv)), :headers => :first_row, :return_headers => false) do |row|
  next if row[0].blank? || row[1].blank?
  codes << [row[0], row[1].to_i]
end

COUNTRY_CALLING_CODES = Hash[codes.uniq]

