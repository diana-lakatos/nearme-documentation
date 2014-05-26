# Simple wrapper for utility methods we need based on the
# user's country.
#
# We might want to extend this to encapsulate more country-specific
# details in the future.
require 'csv'

class Country
  attr_reader :name, :calling_code

  def initialize(attrs)
    @name = attrs[:name]
    @calling_code = attrs[:calling_code]
  end

  def alpha2
    country = IsoCountryCodes.search_by_name(@name).first
    country.alpha2
  rescue
    nil
  end

  class << self
    def countries
      @countries ||= load_countries
    end

    def find(name)
      countries[name]
    end

    def find_by_alpha2(alpha2)
      country = IsoCountryCodes.find(alpha2)
      countries[country.name]
    end

    def all
      countries.values
    end

    def load_countries
      codes = []
      CSV.foreach(Rails.root.join(*%w(config country_calling_codes.csv)), :headers => :first_row, :return_headers => false) do |row|
        next if row[0].blank? || row[1].blank?
        codes << [row[0], row[1].to_i]
      end

      pairs = codes.uniq.map { |name, code|
        [name, Country.new(:name => name, :calling_code => code)]
      }

      Hash[pairs]
    end

    def with_payment_gateway_support
      countries_array = PaymentGateway.countries.map{ |alpha2_code| Country.new(name: IsoCountryCodes.find(alpha2_code).name) || next }
      countries_array.sort { |a,b| a.name <=> b.name }
    end
  end

  load_countries
end

