module TransactablesIndex
  extend ActiveSupport::Concern

  included do |base|
    cattr_accessor :custom_attributes

    settings(index: { number_of_shards: 1 }) do
      mapping do
        indexes :custom_attributes, type: 'object' do
          if TransactableType.table_exists?
            mapped = TransactableType.all.map{ |transactable_type|
              transactable_type.custom_attributes.pluck(:name)
            }.flatten.uniq
            for custom_attribute in mapped
              indexes custom_attribute, type: 'string', index: "not_analyzed"
            end
          end
        end

        indexes :name, type: 'string'
        indexes :description, type: 'string'

        indexes :object_properties, type: 'object'
        indexes :instance_id, :type => 'integer'
        indexes :company_id, :type => 'integer'
        indexes :location_id, :type => 'integer'
        indexes :transactable_type_id, :type => 'integer'
        indexes :administrator_id, :type => 'integer'

        indexes :categories, type: 'integer'

        indexes :enabled, :type => 'boolean'
        indexes :action_rfq, :type => 'boolean'
        indexes :action_free_booking, :type => 'boolean'

        indexes :minimum_price_cents, :type => 'integer'
        indexes :maximum_price_cents, :type => 'integer'
        indexes :all_prices, :type => 'integer'
        indexes :all_price_types, :type => 'string'

        indexes :location_type_id, type: 'integer'

        indexes :geo_location, type: 'geo_point'
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
        indexes :possible_payout, type: 'boolean'
      end
    end

    def as_indexed_json(options={})
      custom_attrs = {}
      custom_attribs = self.transactable_type.cached_custom_attributes.map{ |c| c[0] }

      for custom_attribute in custom_attribs
        if self.properties.respond_to?(custom_attribute)
          val = self.properties.send(custom_attribute)
          val = Array[val].map{|v| v.to_s.downcase }
          custom_attrs[custom_attribute] = (val.size == 1 ? val.first : val)
        end
      end

      allowed_keys = Transactable.mappings.to_hash[:transactable][:properties].keys.delete_if { |prop| prop == :custom_attributes }
      availability_exceptions = self.availability_exceptions ? self.availability_exceptions.map(&:all_dates).flatten : nil
      if self.action_type
        price_types = self.action_type.pricings.map(&:units_to_s)
        price_types << '0_free' if self.action_type.try(:is_free_booking?)
      else
        price_types = []
      end

      self.as_json(only: allowed_keys).merge(
        geo_location: self.geo_location,
        custom_attributes: custom_attrs,
        location_type_id: self.location.try(:location_type_id),
        categories: self.categories.pluck(:id),
        availability: self.schedule_availability,
        availability_exceptions: availability_exceptions,
        all_prices: self.all_prices,
        all_price_types: price_types,
        service_radius: self.properties.try(:service_radius),
        open_hours: self.availability.try(:days_with_hours),
        open_hours_during_week: self.availability.try(:open_hours_during_week),
        completed_reservations: self.reservations.reviewable.count,
        seller_average_rating: self.creator.try(:seller_average_rating)
      )
    end

    def self.esearch(query)
      __elasticsearch__.search(query)
    end

    def self.regular_search(query, transactable_type = nil)
      query_builder = Elastic::QueryBuilder.new(query.with_indifferent_access, searchable_custom_attributes(transactable_type), transactable_type)
      __elasticsearch__.search(query_builder.geo_regular_query)
    end

    def self.searchable_custom_attributes(transactable_type = nil)
      if transactable_type.present?
        # m[0] - name, m[7] - searchable
        transactable_type.cached_custom_attributes.map{|m| "custom_attributes.#{m[0]}" if m[7] == true}.compact.uniq
      else
        TransactableType.where(searchable: true).map{ |transactable_type|
          transactable_type.custom_attributes.where(searchable: true).map{|m| "custom_attributes.#{m.name}"}
        }.flatten.uniq
      end
    end

    def self.geo_search(query, transactable_type = nil)
      query_builder = Elastic::QueryBuilder.new(query.with_indifferent_access, searchable_custom_attributes(transactable_type), transactable_type)
      __elasticsearch__.search(query_builder.geo_query)
    end

    def object_properties
      self.properties.instance_eval{@hash}.to_json
    end

    def geo_location
      {lat: self.location.latitude.to_f, lon: self.location.longitude.to_f} if self.location
    end
  end
end
