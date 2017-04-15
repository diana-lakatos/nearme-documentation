# frozen_string_literal: true
module TransactablesIndex
  extend ActiveSupport::Concern

  included do |_base|
    cattr_accessor :custom_attributes

    settings(index: { number_of_shards: 1 })

    # When changing mappings please remember to write migration to invoke
    # rebuilding/refreshing index For ex. for each Instance perform:
    # ElasticInstanceIndexerJob.perform(update_type: 'refresh', only_classes: ['Transactable'])
    def self.set_es_mapping(instance = PlatformContext.current.try(:instance))

      # TODO: customize relation per mp?
      mapping __index_options(instance) do
        indexes :custom_attributes, type: 'object' do
          if TransactableType.table_exists?
            all_custom_attributes = CustomAttributes::CustomAttribute
                                    .where(target: TransactableType.where(instance: instance))
                                    .pluck(:name, :attribute_type).uniq

            all_custom_attributes.each do |attribute_name, attribute_type|
              type = attribute_type.in?(%w(integer boolean float)) ? attribute_type : 'string'
              indexes attribute_name, type: type, index: 'not_analyzed'
            end
          end
        end

        indexes :name, type: 'string', fields: { raw: { type: 'string', index: 'not_analyzed' } }
        indexes :description, type: 'string'

        indexes :object_properties, type: 'object'
        indexes :instance_id, type: 'integer'
        indexes :company_id, type: 'integer'
        indexes :location_id, type: 'integer'
        indexes :transactable_type_id, type: 'integer'
        indexes :administrator_id, type: 'integer'

        indexes :categories, type: 'integer'

        indexes :enabled, type: 'boolean'
        indexes :action_rfq, type: 'boolean'
        indexes :action_free_booking, type: 'boolean'

        indexes :minimum_price_cents, type: 'integer'
        indexes :maximum_price_cents, type: 'integer'
        indexes :all_prices, type: 'integer'
        indexes :all_price_types, type: 'string'

        indexes :location_type_id, type: 'integer'
        indexes :location_city, type: 'string'
        indexes :location_state, type: 'string'

        indexes :geo_location, type: 'geo_point'
        indexes :geo_service_shape, type: 'geo_shape'
        indexes :service_radius, type: 'integer'
        indexes :open_hours, type: 'integer'
        indexes :open_hours_during_week, type: 'integer'
        indexes :opened_on_days, type: 'integer'

        indexes :availability, type: 'date'
        indexes :availability_exceptions, type: 'date'
        indexes :draft, type: 'date'
        indexes :created_at, type: 'date'
        indexes :completed_reservations, type: 'integer'
        indexes :seller_average_rating, type: 'float'
        indexes :average_rating, type: 'float'
        indexes :possible_payout, type: 'boolean'
        indexes :tags, type: 'string'
        indexes :state, type: 'string'
      end
    end

    def self.__index_options(instance)
      return {} unless instance.multiple_types?

      { _parent: { type: 'user' } }
    end

    def __parent_id
      user.id
    end

    def as_indexed_json(_options = {})
      custom_attrs = {}
      custom_attribs = transactable_type.cached_custom_attributes.map { |c| c[0] }

      for custom_attribute in custom_attribs
        next unless properties.respond_to?(custom_attribute)
        val = properties.send(custom_attribute)
        val = Array(val).map { |v| v.to_s.downcase }
        custom_attrs[custom_attribute] = (val.size == 1 ? val.first : val)
      end

      allowed_keys = Transactable.mappings.to_hash[:transactable][:properties].keys.delete_if { |prop| prop == :custom_attributes }
      availability_exceptions = self.availability_exceptions ? self.availability_exceptions.map(&:all_dates).flatten : nil
      if action_type
        price_types = action_type.pricings.map(&:units_to_s)
        price_types << '0_free' if action_type.try(:is_free_booking?)
      else
        price_types = []
      end

      as_json(only: allowed_keys).merge(
        geo_location: geo_location,
        geo_service_shape: geo_service_shape,
        custom_attributes: custom_attrs,
        location_type_id: location.try(:location_type_id),
        location_city: location.try(:city).try(:downcase).try(:gsub, ' ', '_'),
        location_state: location.try(:state).try(:downcase).try(:gsub, ' ', '_'),
        categories: categories.pluck(:id),
        availability: schedule_availability,
        availability_exceptions: availability_exceptions,
        all_prices: all_prices,
        all_price_types: price_types,
        service_radius: properties.try(:service_radius),
        open_hours: availability.try(:days_with_hours),
        open_hours_during_week: availability.try(:open_hours_during_week),
        completed_reservations: orders.reservations.reviewable.count,
        seller_average_rating: creator.try(:seller_average_rating),
        tags: tags_as_comma_string,
        state: state
      )
    end

    def geo_service_shape
      if properties.respond_to?(:service_radius)
        {
          type: 'circle',
          coordinates: [location.longitude.to_f, location.latitude.to_f],
          radius: "#{properties.service_radius}mi"
        }
      end
    end

    def self.esearch(query)
      __elasticsearch__.search(query)
    end

    def self.regular_search(query, transactable_type = nil)
      query_builder = ::Elastic::QueryBuilderBase.new(query.with_indifferent_access, searchable_custom_attributes(transactable_type), transactable_type)
      __elasticsearch__.search(query_builder.geo_regular_query)
    end

    def self.searchable_custom_attributes(transactable_type = nil)
      if transactable_type.present?
        transactable_type.cached_custom_attributes.map do |custom_attribute|
          if custom_attribute[CustomAttributes::CustomAttribute::SEARCH_IN_QUERY]
            "custom_attributes.#{custom_attribute[CustomAttributes::CustomAttribute::NAME]}"
          end
        end.compact.uniq
      else
        TransactableType.where(searchable: true).map do |tt|
          tt.custom_attributes.where(searchable: true).map { |m| "custom_attributes.#{m.name}" }
        end.flatten.uniq
      end
    end

    def self.geo_search(query, transactable_type = nil)
      query_builder = ::Elastic::QueryBuilderBase.new(query.with_indifferent_access, searchable_custom_attributes(transactable_type), transactable_type)
      __elasticsearch__.search(query_builder.geo_query)
    end

    def object_properties
      properties.instance_eval { @hash }.to_json
    end

    def geo_location
      { lat: location.latitude.to_f, lon: location.longitude.to_f } if location
    end
  end
end
