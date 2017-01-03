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
        indexes :first_name, type: 'string'
        indexes :last_name, type: 'string'
        indexes :name, type: 'string'

        indexes :country_name, type: 'string'
        indexes :company_name, type: 'string'

        indexes :tags, type: 'string'

        indexes :instance_id, type: 'integer'
        indexes :instance_profile_type_ids, type: 'integer'
        indexes :number_of_completed_orders, type: 'integer'
        indexes :seller_average_rating, type: 'float'
        indexes :buyer_average_rating, type: 'float'

        indexes :user_profiles, type: 'nested' do
          indexes :enabled, type: 'boolean'
          indexes :availability_exceptions, type: 'date'
          indexes :profile_type, type: 'string'
          indexes :category_ids, type: 'integer'
          indexes :customizations, type: 'object' do
            CustomAttributes::CustomAttribute.custom_attributes_mapper(CustomModelType, CustomModelType.user_profiles) do |attribute_name, type|
              indexes attribute_name, type: type, fields: { 'raw': { type: type, index: 'not_analyzed' } }
            end
          end
          indexes :properties, type: 'object' do
            CustomAttributes::CustomAttribute.custom_attributes_mapper(InstanceProfileType, InstanceProfileType.where(instance: instance)) do |attribute_name, type|
              indexes attribute_name, type: type, fields: { 'raw': { type: type, index: 'not_analyzed' } }
            end
          end
        end
      end
    end

    def as_indexed_json(_options = {})
      profiles = user_profiles.map do |user_profile|

        customizations_attributes = user_profile.customizations.map do |customization|
          CustomAttributes::CustomAttribute.custom_attributes_indexer(CustomModelType, customization)
        end

        Time.use_zone(time_zone) do
          @availability_exceptions = user_profile.availability_exceptions ? user_profile.availability_exceptions.map(&:all_dates).flatten : nil
        end

        user_profile.slice(:instance_profile_type_id, :profile_type, :enabled).merge(
          availability_exceptions: @availability_exceptions,
          properties: CustomAttributes::CustomAttribute.custom_attributes_indexer(InstanceProfileType, user_profile),
          category_ids: user_profile.categories.map(&:id),
          customizations: customizations_attributes
        )
      end

      as_json(only: User.mappings.to_hash[:user][:properties].keys).merge(
        instance_profile_type_ids: user_profiles.map(&:instance_profile_type_id),
        tags: tags_as_comma_string,
        user_profiles: profiles,
        number_of_completed_orders: listing_orders.reservations.reviewable.count
      )
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
