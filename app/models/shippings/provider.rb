# frozen_string_literal: true
module Shippings
  class Provider < OpenStruct
    def self.find(name)
      all.find { |p| p.name == name }
    end

    def self.for(instance)
      all.select do |provider|
        (provider.countries & instance.allowed_countries).any?
      end
    end

    def self.all
      from_file.map { |p| Provider.new(p) }
    end

    def self.from_file
      YAML.load_file File.join(__dir__, 'providers.yml')
    end
  end
end
