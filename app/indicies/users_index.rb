# frozen_string_literal: true
module UsersIndex
  extend ActiveSupport::Concern

  included do |_base|
    cattr_accessor :custom_attributes

    settings(index: { number_of_shards: 1 })

    # When changing mappings please remember to write migration to invoke
    # rebuilding/refreshing index. For ex. for each Instance perform:
    # ElasticInstanceIndexerJob.perform(update_type: 'refresh', only_classes: ['User'])
    def self.set_es_mapping(instance = PlatformContext.current.try(:instance))
      mapping do
        indexes :email, type: 'string'
        indexes :first_name, type: 'string'
        indexes :last_name, type: 'string'
        indexes :name, type: 'string'
        indexes :slug, type: 'string', index: 'not_analyzed'
        indexes :created_at, type: 'date'

        indexes :country_name, type: 'string'
        indexes :company_name, type: 'string'

        indexes :blog, type: 'object' do
          indexes :name
          indexes :enabled, type: 'boolean'
        end

        indexes :avatar, type: 'object' do
          indexes :url
        end

        indexes :communication do
          indexes :verified, type: 'boolean'
        end

        indexes :tags, type: 'string'

        indexes :instance_id, type: 'integer'
        indexes :instance_profile_type_ids, type: 'integer'
        indexes :number_of_completed_orders_creator, type: 'integer'
        indexes :number_of_completed_orders_user, type: 'integer'
        indexes :seller_average_rating, type: 'float'
        indexes :buyer_average_rating, type: 'float'
        indexes :geo_location, type: 'geo_point'
        indexes :geo_service_shape, type: 'geo_shape'

        indexes :user_profiles, type: 'nested' do
          indexes :enabled, type: 'boolean'
          indexes :availability_exceptions, type: 'date'
          indexes :profile_type, type: 'string'
          indexes :category_ids, type: 'integer'
          indexes :categories, type: 'nested' do
            indexes :id, type: 'integer'
            indexes :name, type: 'string'
            indexes :permalink, type: 'string', index: 'not_analyzed'
            indexes :root, type: 'string'
            indexes :position, type: 'integer'
          end

          # TODO: add _nested_ mapping for custom-models
          # indexes :customizations, type: 'object' do
          #   CustomAttributes::CustomAttribute.custom_attributes_mapper(CustomModelType, CustomModelType.user_profiles) do |attribute_name, type|
          #     indexes attribute_name, type: type, fields: { raw: { type: type, index: 'not_analyzed' } }
          #   end
          # end
          indexes :properties, type: 'object' do
            CustomAttributes::CustomAttribute.custom_attributes_mapper(InstanceProfileType, InstanceProfileType.where(instance: instance)) do |attribute_name, type|
              indexes attribute_name, type: type, fields: { raw: { type: type, index: 'not_analyzed' } }
            end
          end
        end
      end
    end

    def as_indexed_json(_options = {})
      ElasticIndexer::UserSerializer.new(self).as_json
    end

    def self.esearch(query)
      __elasticsearch__.search(query)
    end

    def self.regular_search(query, instance_profile_type = nil)
      query_builder = Elastic::QueryBuilder::UsersQueryBuilder.new(query.with_indifferent_access,
                                                                   searchable_custom_attributes: searchable_custom_attributes(instance_profile_type),
                                                                   query_searchable_attributes: search_in_query_custom_attributes(instance_profile_type),
                                                                   instance_profile_type: instance_profile_type)

      __elasticsearch__.search(query_builder.regular_query)
    end

    def self.simple_search(query, instance_profile_types:, instance_profile_type: nil)
      query_builder = Elastic::QueryBuilder::UsersQueryBuilder.new(query.with_indifferent_access,
                                                                   searchable_custom_attributes: searchable_custom_attributes(instance_profile_type),
                                                                   query_searchable_attributes: search_in_query_custom_attributes(instance_profile_type),
                                                                   instance_profile_type: instance_profile_type,
                                                                   instance_profile_types: instance_profile_types)

      __elasticsearch__.search(query_builder.simple_query)
    end

    def self.search_in_query_custom_attributes(instance_profile_type)
      if instance_profile_type.present?
        instance_profile_type.cached_custom_attributes.map do |custom_attribute|
          if custom_attribute[CustomAttributes::CustomAttribute::SEARCH_IN_QUERY]
            "user_profiles.properties.#{custom_attribute[CustomAttributes::CustomAttribute::NAME]}"
          end
        end.compact.uniq
      end
    end

    def self.searchable_custom_attributes(instance_profile_type)
      if instance_profile_type.present?
        instance_profile_type.cached_custom_attributes.map do |custom_attribute|
          if custom_attribute[CustomAttributes::CustomAttribute::SEARCHABLE]
            "user_profiles.properties.#{custom_attribute[CustomAttributes::CustomAttribute::NAME]}"
          end
        end.compact.uniq
      else
        InstanceProfileType.where(searchable: true).map do |ipt|
          ipt.custom_attributes.where(searchable: true).map do |custom_attribute|
            "user_profiles.properties.#{custom_attribute.name}"
          end
        end.flatten.uniq
      end
    end
  end
end
