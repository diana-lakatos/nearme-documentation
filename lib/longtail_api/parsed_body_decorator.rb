# frozen_string_literal: true
class LongtailApi
  class ParsedBodyDecorator
    SIMPLE_KEY_VALUE_EXTENSIONS = {
      'address' => 'formatted_address',
      'latitude' => 'latitude',
      'longitude' => 'longitude',
      'currency' => 'currency'
    }.freeze

    class << self
      def decorate(parsed_body)
        parsed_body['included'].each_with_index do |item, index|
          @transactable = Transactable.with_deleted.find_by(id: item['attributes']['guid'])
          next if @transactable.nil?
          new(transactable: @transactable, hash: parsed_body['included'][index]['attributes']).decorate
        end
      end
    end

    def initialize(transactable:, hash:)
      @transactable = transactable
      @hash = hash
    end

    def decorate
      add_pricings
      add_photos
      add_simple_extensions
      add_custom_attributes
      add_categories
    end

    protected

    def add_pricings
      @hash['price'] ||= {}
      @transactable.action_type.pricings.each do |pricing|
        add_attribute(hash: @hash['price'], key: pricing.unit, value: pricing.price.to_s)
      end
    end

    def add_photos
      add_attribute(hash: @hash, key: 'photos', value: @transactable.photos_metadata.try(:map) { |p| p['space_listing'] })
    end

    def add_simple_extensions
      SIMPLE_KEY_VALUE_EXTENSIONS.each do |key, method|
        add_attribute(hash: @hash, key: key, value: @transactable.send(method))
      end
    end

    def add_custom_attributes
      @transactable.properties.to_h.each { |k, v| add_attribute(hash: @hash, key: k, value: v) }
    end

    def add_categories
      add_attribute(hash: @hash, key: 'categories', value: @transactable.to_liquid.categories)
    end

    def add_attribute(hash:, key:, value:)
      hash[key] = value
    end
  end
end
