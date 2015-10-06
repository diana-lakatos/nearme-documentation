module ProductsIndex
  extend ActiveSupport::Concern

  included do |base|
    cattr_accessor :custom_attributes

    settings(
      index: {
        number_of_shards: 1,
        analysis: {
          analyzer: {
            custom_analyzer: {
              type: 'custom',
              tokenizer: 'whitespace',
              filter: ["standard", "lowercase"]
            }
          }
        }
      }
    ) do
      mapping do
        indexes :custom_attributes, type: 'object' do
          if Rails.env.staging? || Rails.env.production?
            mapped = Spree::ProductType.all.map{ |product_type|
              product_type.custom_attributes.map(&:name)
            }.flatten.uniq
            for custom_attribute in mapped
              indexes custom_attribute, type: 'string'
            end
          end
        end

        indexes :categories, type: 'integer'

        indexes :object_properties, type: 'object'

        indexes :name, :type => 'string'
        indexes :description, :type => 'string'

        indexes :instance_id, :type => 'integer'
        indexes :user_id, :type => 'integer'
        indexes :product_type_id, :type => 'integer'

        indexes :approved, :type => 'boolean'
        indexes :action_rfq, :type => 'boolean'

        indexes :available_on, type: 'date'
        indexes :created_at, type: 'date'

        indexes :geo_location, type: 'geo_point'
        indexes :price, type: 'float'
      end
    end

    def as_indexed_json(options={})
      return {}.to_json if self.product_type.blank? || self.master.blank?
      custom_attrs = {}
      custom_attribs = self.product_type.cached_custom_attributes.map{ |c| c[0] }

      for custom_attribute in custom_attribs
        custom_attrs[custom_attribute] = self.extra_properties.send(custom_attribute).to_s if self.extra_properties.respond_to?(custom_attribute)
      end

      allowed_keys = Spree::Product.mappings.to_hash[:product][:properties].keys.delete_if { |prop| prop == :custom_attributes }

      self.as_json(only: allowed_keys).merge(
        {
          geo_location: self.geo_location,
          price: self.price,
          custom_attributes: custom_attrs,
          categories: self.categories.pluck(:id)
        }
      )

    end

    def self.searchable_custom_attributes(product_type = nil)
      if product_type
        # m[0] - name, m[7] - searchable
        product_type.cached_custom_attributes.map{|m| "custom_attributes.#{m[0]}^3" if m[7] == true}.compact
      else
        Spree::ProductType.where(searchable: true).map{ |product_type|
          product_type.custom_attributes.where(searchable: true).pluck(:name)
        }.flatten.uniq.map{|m| "custom_attributes.#{m}^3"}
      end
    end

    def self.search(query, product_type = nil)
      query_builder = Elastic::QueryBuilder.new(query.with_indifferent_access, searchable_custom_attributes(product_type))
      __elasticsearch__.search(query_builder.product_query)
    end

    def geo_location
      {lat: self.location.latitude, lon: self.location.longitude} if self.respond_to?(:location) and self.location
    end

    def object_properties
      self.extra_properties.instance_eval{@hash}.to_json
    end
  end
end