module UsersIndex

  extend ActiveSupport::Concern

  included do |base|
    cattr_accessor :custom_attributes

    settings(index: { number_of_shards: 1 }) do
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
          indexes :profile_type, type: 'string'
          indexes :category_ids, type: 'integer'
          indexes :properties, type: 'object' do
            if InstanceProfileType.table_exists?
              mapped = InstanceProfileType.all.map{ |instance_profile_type|
                instance_profile_type.custom_attributes
              }.flatten

              mapped.each do |custom_attribute|
                type = custom_attribute.attribute_type.in?(['integer', 'boolean', 'float']) ? custom_attribute.attribute_type : 'string'
                indexes custom_attribute.name, type: type, index: 'not_analyzed'
              end
            end
          end
        end
      end
    end

    def as_indexed_json(options = {})
      custom_attributes = {}

      custom_attributes_by_type = InstanceProfileType.all.map do |instance_profile_type|
        instance_profile_type.custom_attributes.pluck(:name)
      end.flatten.uniq

      profiles = self.user_profiles.map do |user_profile|
        custom_attributes_by_type.each do |custom_attribute|
          if user_profile.properties.respond_to?(custom_attribute)
            val = user_profile.properties.send(custom_attribute)
            val = Array(val).map{|v| v.to_s.downcase }
            if custom_attributes[custom_attribute].present?
              (Array(custom_attributes[custom_attribute]) + val).flatten
            else
              custom_attributes[custom_attribute] = (val.size == 1 ? val.first : val)
            end
          end
        end

        user_profile.slice(:instance_profile_type_id, :profile_type, :enabled).merge({
          properties: custom_attributes,
          category_ids: user_profile.categories.map(&:id)
        })
      end

      allowed_keys = User.mappings.to_hash[:user][:properties].keys.delete_if { |prop| prop == :custom_attributes }

      self.as_json(only: allowed_keys).merge(
        instance_profile_type_ids: self.user_profiles.map(&:instance_profile_type_id),
        custom_attributes: custom_attributes,
        tags: self.tags_as_comma_string,
        user_profiles: profiles
      )
    end

    def self.esearch(query)
      __elasticsearch__.search(query)
    end

    def self.regular_search(query, instance_profile_type = nil)
      query_builder = Elastic::QueryBuilder::UsersQueryBuilder.new(
        query.with_indifferent_access,
        searchable_custom_attributes(instance_profile_type),
        instance_profile_type
      )

      __elasticsearch__.search(query_builder.regular_query)
    end

    def self.searchable_custom_attributes(instance_profile_type = nil)
      if instance_profile_type.present?
        # m[0] - name, m[7] - searchable
        instance_profile_type.cached_custom_attributes.map do |custom_attribute|
          "user_profiles.properties.#{ custom_attribute[0] }" if custom_attribute[7] == true
        end.compact.uniq
      else
        InstanceProfileType.where(searchable: true).map do |instance_profile_type|
          instance_profile_type.custom_attributes.where(searchable: true).map do |custom_attribute|
            "user_profiles.properties.#{custom_attribute.name}"
          end
        end.flatten.uniq
      end
    end

  end
end