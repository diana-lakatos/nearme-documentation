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

        indexes :booking_type, :type => 'string'
        indexes :enabled, :type => 'boolean'
        indexes :action_rfq, :type => 'boolean'
        indexes :action_recurring_booking, :type => 'boolean'
        indexes :action_free_booking, :type => 'boolean'
        indexes :action_hourly_booking, :type => 'boolean'
        indexes :action_daily_booking, :type => 'boolean'
        indexes :action_weekly_booking, :type => 'boolean'
        indexes :action_monthly_booking, :type => 'boolean'
        indexes :action_subscription_booking, :type => 'boolean'

        indexes :hourly_price_cents, :type => 'integer'
        indexes :daily_price_cents, :type => 'integer'
        indexes :weekly_price_cents, :type => 'integer'
        indexes :monthly_price_cents, :type => 'integer'
        indexes :weekly_subscription_price_cents, :type => 'integer'
        indexes :monthly_subscription_price_cents, :type => 'integer'
        indexes :fixed_price_cents, :type => 'integer'
        indexes :exclusive_price_cents, :type => 'integer'
        indexes :minimum_price_cents, :type => 'integer'
        indexes :maximum_price_cents, :type => 'integer'
        indexes :all_prices, :type => 'integer'

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
      custom_attribs = self.service_type.cached_custom_attributes.map{ |c| c[0] }

      for custom_attribute in custom_attribs
        if self.properties.respond_to?(custom_attribute)
          custom_attrs[custom_attribute] = self.properties.send(custom_attribute).to_s.downcase
        end
      end

      allowed_keys = Transactable.mappings.to_hash[:transactable][:properties].keys.delete_if { |prop| prop == :custom_attributes }

      self.as_json(only: allowed_keys).merge(
        geo_location: self.geo_location,
        custom_attributes: custom_attrs,
        location_type_id: self.location.try(:location_type_id),
        hourly_price_cents: self.hourly_price_cents.to_i,
        daily_price_cents: self.daily_price_cents.to_i,
        weekly_price_cents: self.weekly_price_cents.to_i,
        monthly_price_cents: self.monthly_price_cents.to_i,
        categories: self.categories.pluck(:id),
        availability: self.schedule_availability,
        availability_exceptions: self.availability_exceptions.map(&:all_dates).flatten,
        action_monthly_booking: !self.monthly_price_cents.to_i.zero?,
        action_weekly_booking: !self.weekly_price_cents.to_i.zero?,
        all_prices: self.all_prices,
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

    def self.regular_search(query, service_type = nil)
      query_builder = Elastic::QueryBuilder.new(query.with_indifferent_access, searchable_custom_attributes(service_type), service_type)
      __elasticsearch__.search(query_builder.geo_regular_query)
    end

    def self.searchable_custom_attributes(service_type = nil)
      if service_type.present?
        # m[0] - name, m[7] - searchable
        service_type.cached_custom_attributes.map{|m| "custom_attributes.#{m[0]}" if m[7] == true}.compact.uniq
      else
        ServiceType.where(searchable: true).map{ |service_type|
          service_type.custom_attributes.where(searchable: true).map{|m| "custom_attributes.#{m.name}"}
        }.flatten.uniq
      end
    end

    def self.geo_search(query, service_type = nil)
      query_builder = Elastic::QueryBuilder.new(query.with_indifferent_access, searchable_custom_attributes(service_type), service_type)
      __elasticsearch__.search(query_builder.geo_query)
    end

    def object_properties
      self.properties.instance_eval{@hash}.to_json
    end

    def geo_location
      {lat: self.location.latitude, lon: self.location.longitude} if self.location
    end
  end
end
