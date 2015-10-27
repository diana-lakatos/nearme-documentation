class PopulateCompaniesAddresses < ActiveRecord::Migration

  class User < ActiveRecord::Base
  end

  class Company < ActiveRecord::Base
    belongs_to :creator, class_name: "User"
    has_many :locations
    has_one :company_address, class_name: 'Address', as: :entity
  end

  class Location < ActiveRecord::Base
    has_one :location_address, class_name: 'Address', as: :entity
  end

  class Address < ActiveRecord::Base
    class AddressComponentsPopulator

      LIMIT = 500

      attr_accessor :result

      def initialize(location = nil, options = {})
        @location = location
        @show_inspections = options.fetch(:show_inspections,false)
      end

      def geocode
        @result = Geocoder.search(@location.read_attribute(:address)).first
      end

      def wrapped_address_components
        wrapper_hash = {}
        @result.address_components.each_with_index do |address_component_hash, index|
          wrapper_hash["#{index}"] = address_component_hash
        end
        wrapper_hash
      end

    end

    class GoogleGeolocationDataParser

      attr :address_components, :result_hash

      MAPPING_HASH = {
        "route" => "street",
        "country" => "country",
        "locality"  =>  "city",
        "sublocality" => "suburb",
        "administrative_area_level_1" => "state",
        "postal_code" => "postcode"
      }


      def initialize(address_components)
        @result_hash = {}
        return unless address_components
        @address_components = address_components.to_enum.map { |c| Component.new(c[1]) }
        MAPPING_HASH.each_pair do |type, field_on_location|
          component = find_component_for(type)
          result_hash[field_on_location] = {long: component.long_name, short: component.short_name}
        end
      end

      def fetch_address_component(name, name_type = :long)
        result_hash.fetch(name, {}).fetch(name_type, nil)
      end

      private
      def find_component_for(type)
        component = address_components.find do |c|
          c.types.include?(type)
        end || Component.new({ "long_name" => "", "short_name" => "", "types" => ""})

        if type == "locality" and component.missing?
          component = find_component_for("administrative_area_level_3")
        end
        if type == "sublocality" and component.missing?
          component = find_component_for("neighborhood")
        end
        component
      rescue
        Component.new({ "long_name" => "", "short_name" => "", "types" => ""})
      end

      class Component
        attr_reader :long_name, :short_name, :types
        def initialize(hash)
          @long_name = hash.fetch("long_name", "")
          @short_name = hash.fetch("short_name", "")
          @types = hash.fetch("types", "").split(",")[0]
        end

        def missing?
          long_name.empty?
        end
      end
    end

    belongs_to :entity, polymorphic: true
    serialize :address_components, JSON

    def fetch_coordinates!
      populator = AddressComponentsPopulator.new(self)
      geocoded = populator.geocode
      if geocoded
        self.latitude = geocoded.coordinates[0]
        self.longitude = geocoded.coordinates[1]
        self.formatted_address = geocoded.formatted_address
        self.address_components = populator.wrapped_address_components
      else
        # do not allow to save when cannot geolocate
        self.latitude = nil
        self.longitude = nil
      end
    end

    def parse_address_components!
      data_parser = Address::GoogleGeolocationDataParser.new(address_components)
      self.city = data_parser.fetch_address_component("city")
      self.suburb = data_parser.fetch_address_component("suburb")
      self.street = data_parser.fetch_address_component("street")
      self.country = data_parser.fetch_address_component("country")
      self.iso_country_code = data_parser.fetch_address_component("country", :short)
      self.state = data_parser.fetch_address_component("state")
      self.postcode = data_parser.fetch_address_component("postcode")
    end
  end

  class Country

    def initialize(attrs)
      @name = attrs[:name]
      @calling_code = attrs[:calling_code]
    end

    class << self
      def countries
        @countries ||= load_countries
      end

      def find_by_iso(alpha2)
        country = IsoCountryCodes.find(alpha2)
        countries[country.name]
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
  end


  def up
    add_column :addresses, :iso_country_code, :string, limit: 2
    wrong = []
    correct = []
    puts "Populating addresses without correct country..."
    Address.all.select { |a| a.iso_country_code.nil? || Country.find_by_alpha2(a.iso_country_code) }.each do |a|
      puts "re-fetching address #{a.id}"
      if a.address_components.present?
        a.parse_address_components!
      end
      if a.iso_country_code.blank? || Country.find_by_alpha2(a.iso_country_code).nil?
        a.fetch_coordinates!
        a.parse_address_components!
      end
      a.save(validate: false)
      if a.iso_country_code.blank?
        puts "Address #{a.id} still has blank country code"
      end
    end
    puts "Populating addresses done!"

    Company.find_each do |c|
      if Address.where(entity_id: c.id, entity_type: 'Company').first.nil? && c.locations.first.present? && (la = Address.where(entity_id: c.locations.first.id, entity_type: 'Location').first) && la.country.present?
        correct << c.id
        Address.create(formatted_address: la.formatted_address, latitude: la.latitude, longitude: la.longitude, address: la.address, address_components: la.address_components, state: la.state, postcode: la.postcode, city: la.city, suburb: la.suburb, street: la.street, country: la.country, iso_country_code: la.iso_country_code, entity_id: c.id, entity_type: 'Company', instance_id: c.instance_id)
      else
        wrong << c.id
        if c.locations.first.nil?
          puts "Company #{c.name} (id=#{c.id}): does not have location"
        elsif la.nil?
          puts "Company #{c.name} (id=#{c.id}) Location does not have address"
        elsif la.country.blank?
          puts "Company #{c.name} (id=#{c.id}): Location country is nil"
        end
      end
    end

    puts "Populated: #{correct.count}"
    puts "Wrong: #{wrong.count}"
  end

  def down
    remove_column :addresses, :iso_country_code
  end

end
