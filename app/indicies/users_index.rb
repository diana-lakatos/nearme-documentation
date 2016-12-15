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

        indexes :user_profiles, type: 'nested' do
          indexes :enabled, type: 'boolean'
          indexes :availability_exceptions, type: 'date'
          indexes :profile_type, type: 'string'
          indexes :category_ids, type: 'integer'
          indexes :properties, type: 'object' do
            if InstanceProfileType.table_exists?
              all_custom_attributes = CustomAttributes::CustomAttribute
                                      .where(target: InstanceProfileType.where(instance: instance))
                                      .pluck(:name, :attribute_type).uniq

              all_custom_attributes.each do |attribute_name, attribute_type|
                type = attribute_type.in?(%w(integer boolean float)) ? attribute_type : 'string'
                indexes attribute_name, type: type, fields: { 'raw': { type: type, index: 'not_analyzed' } }
              end
            end
          end
        end
      end
    end

    def as_indexed_json(_options = {})
      custom_attributes_by_type = InstanceProfileType.all.map do |instance_profile_type|
        instance_profile_type.custom_attributes.pluck(:name)
      end.flatten.uniq

      profiles = user_profiles.map do |user_profile|
        custom_attributes = {}
        custom_attributes_by_type.each do |custom_attribute|
          next unless user_profile.properties.respond_to?(custom_attribute)
          val = user_profile.properties.send(custom_attribute)
          val = Array(val).map { |v| v.to_s.downcase }
          if custom_attributes[custom_attribute].present?
            (Array(custom_attributes[custom_attribute]) + val).flatten
          else
            custom_attributes[custom_attribute] = (val.size == 1 ? val.first : val)
          end
        end
        availability_exceptions = user_profile.availability_exceptions ? user_profile.availability_exceptions.map(&:all_dates).flatten : nil

        user_profile.slice(:instance_profile_type_id, :profile_type, :enabled).merge(
          availability_exceptions: availability_exceptions,
          properties: custom_attributes,
          category_ids: user_profile.categories.map(&:id)
        )
      end

      as_json(only: User.mappings.to_hash[:user][:properties].keys).merge(
        instance_profile_type_ids: user_profiles.map(&:instance_profile_type_id),
        tags: tags_as_comma_string,
        user_profiles: profiles
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
