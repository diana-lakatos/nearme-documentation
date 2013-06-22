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

  class << self
    def countries
      @countries ||= load_countries
    end

    def find(name)
      countries[name]
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
  end

  load_countries
end

