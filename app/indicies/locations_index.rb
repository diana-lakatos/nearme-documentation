# frozen_string_literal: true
module LocationsIndex
  extend ActiveSupport::Concern

  included do |_base|
    settings(index: { number_of_shards: 1 })

    def self.build_es_mapping(options: {})
      # TODO: customize relation per mp?
      mapping(options) do
        indexes :name, type: 'string', fields: { raw: { type: 'string', index: 'not_analyzed' } }

        indexes :email, type: 'string'
        indexes :slug, type: 'string', index: 'not_analyzed'
        indexes :instance_id, type: 'integer'
        indexes :description, type: 'string'

        indexes :geo_location, type: 'geo_point'
        indexes :geo_service_shape, type: 'geo_shape'

        indexes :latitude, type: 'float'
        indexes :longitude, type: 'float'
        indexes :info, type: 'string'
        indexes :created_at, type: 'date'
        indexes :updated_at, type: 'date'
        indexes :deleted_at, type: 'date'
        indexes :formatted_address, type: 'string'
        indexes :street, type: 'string'
        indexes :suburb, type: 'string'
        indexes :city, type: 'string'
        indexes :state, type: 'string'
        indexes :country, type: 'string'
        indexes :postcode, type: 'string'

        indexes :deprecated_currency, type: 'string'

        indexes :special_notes, type: 'string'

        indexes :address2, type: 'string'
        indexes :administrator_id, type: 'integer'
        indexes :creator_id, type: 'integer'
        indexes :listings_public, type: 'boolean'

        indexes :address_id, type: 'integer'
        indexes :wish_list_items_count, type: 'integer'
        indexes :opened_on_days, type: 'integer'
        indexes :time_zone, type: 'string'
        indexes :availability_template_id, type: 'integer'
        indexes :impressions_count, type: 'integer'
      end
    end

    def as_indexed_json(_options = {})
      as_json(except: [:address_components, :metadata, :address])
    end
  end
end
