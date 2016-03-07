module OffersIndex
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
            mapped = OfferType.all.map{ |offer_type|
              offer_type.custom_attributes.map(&:name)
            }.flatten.uniq
            for custom_attribute in mapped
              indexes custom_attribute, type: 'string'
            end
          end
        end

        indexes :name, :type => 'string'
        indexes :description, :type => 'string'
        indexes :summary, :type => 'string'
        indexes :categories, type: 'integer'

        indexes :instance_id, :type => 'integer'
        indexes :owner_id, :type => 'integer'
        indexes :transactable_type_id, :type => 'integer'
      end
    end

    def as_indexed_json(options={})
      return {}.to_json if self.offer_type.blank?
      custom_attrs = {}
      custom_attribs = self.offer_type.cached_custom_attributes.map{ |c| c[0] }

      for custom_attribute in custom_attribs
        custom_attrs[custom_attribute] = self.properties.send(custom_attribute).to_s if self.properties.respond_to?(custom_attribute)
      end

      allowed_keys = Offer.mappings.to_hash[:offer][:properties].keys.delete_if { |prop| prop == :custom_attributes }

      self.as_json(only: allowed_keys).merge(
        {
          price: self.price,
          custom_attributes: custom_attrs,
          categories: self.categories.pluck(:id)
        }
      )

    end

    def self.searchable_custom_attributes(offer_type = nil)
      if offer_type
        # m[0] - name, m[7] - searchable
        offer_type.cached_custom_attributes.map{|m| "custom_attributes.#{m[0]}^3" if m[7] == true}.compact
      else
        OfferType.where(searchable: true).map{ |offer_type|
          offer_type.custom_attributes.where(searchable: true).pluck(:name)
        }.flatten.uniq.map{|m| "custom_attributes.#{m}^3"}
      end
    end

    def self.search(query, offer_type = nil)
      query_builder = Elastic::QueryBuilder.new(query.with_indifferent_access, searchable_custom_attributes(offer_type), offer_type)
      __elasticsearch__.search(query_builder.offer_type)
    end

    # def geo_location
    #   {lat: self.location.latitude, lon: self.location.longitude} if self.respond_to?(:location) and self.location
    # end

    def object_properties
      self.properties.instance_eval{@hash}.to_json
    end
  end
end