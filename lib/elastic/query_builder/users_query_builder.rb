# frozen_string_literal: true
module Elastic
  class QueryBuilder
    class UsersQueryBuilder < QueryBuilder
      def initialize(query, instance_profile_type:, searchable_custom_attributes: [], query_searchable_attributes: [])
        @query = query

        @searchable_custom_attributes = searchable_custom_attributes
        @query_searchable_attributes = query_searchable_attributes
        @instance_profile_type = instance_profile_type

        @filters = []
        @not_filters = []
      end

      def regular_query
        @filters = profiles_filters

        {
          sort: sorting_options,
          query: match_query,
          filter: { bool: { must: @filters } }
        }.merge(aggregations)
      end

      def match_query
        if @query[:query].blank?
          { match_all: { boost: QUERY_BOOST } }
        else
          match_bool_condition = {
            bool: {
              should: [
                simple_match_query
              ]
            }
          }

          match_bool_condition[:bool][:should] << multi_match_query if @query_searchable_attributes.present?

          match_bool_condition
        end
      end

      def simple_match_query
        {
          simple_query_string: {
            query: @query[:query],
            fields: search_by_query_attributes
          }
        }
      end

      def multi_match_query
        {
          nested: {
            path: 'user_profiles',
            query: {
              multi_match: {
                query: @query[:query],
                fields: search_by_query_attributes
              }
            }
          }
        }
      end

      def search_by_query_attributes
        searchable_main_attributes + @query_searchable_attributes
      end

      def searchable_main_attributes
        ['name^2', 'tags^10', 'company_name']
      end

      def sorting_options
        sorting_fields = []

        if @query[:sort].present?
          sorting_fields = @query[:sort].split(',').compact.map do |sort_option|
            next unless sort = sort_option.match(/([a-zA-Z\.\_\-]*)_(asc|desc)/)

            default_user_profile_body = {
              order: sort[2],
              nested_path: 'user_profiles',
              nested_filter: {
                term: {
                  'user_profiles.instance_profile_type_id': @instance_profile_type.id
                }
              }
            }

            body = default_user_profile_body

            if sort[1].split('.').first == 'custom_attributes'
              sort_column = "user_profiles.properties.#{sort[1].split('.').last}.raw"
            elsif sort[1].split('.').first == 'user'
              sort_column = sort[1].split('.').last
              body = sort[2]
            else
              sort_column = sort[1]
            end

            {
              sort_column => body
            }
          end.compact
        end

        return ['_score'] if sorting_fields.empty?

        sorting_fields
      end

      # TODO: rebuild and use new aggregation builder
      def aggregation_fields
        InstanceProfileType
          .all
          .flat_map { |p| p.custom_attributes.where(aggregate_in_search: true) }
          .map do |attr|
          {
            label: attr.name,
            field: "user_profiles.properties.#{attr.name}.raw",
            size: attr.valid_values.size + 1 # plus one extra for empty
          }
        end
      end

      # TODO: query builder should rely on query params not some globals
      def profiles_filters
        PlatformContext.current.instance.instance_profile_types.searchable.map do |profile|
          build_profile_query(profile)
        end
      end

      def default_profile_query
        user_profiles_filters = Elastic::QueryBuilder::UserProfileBuilder.build(@query, type: 'default')

        # legacy and deprecated
        @query[:lg_custom_attributes]&.each do |key, value|
          next if value.blank?
          attribute = key.match(/([a-zA-Z\.\_\-]*)_(gte|lte|gt|lt)/)
          if attribute
            user_profiles_filters << { range: { "user_profiles.properties.#{attribute[1]}.raw" => { attribute[2] => value.to_f } } }
          else
            Array(value).reject(&:blank?).each do |single|
              user_profiles_filters << { match: { "user_profiles.properties.#{key}" => single } }
            end
          end
        end

        # legacy and deprecated
        @query[:lg_customizations]&.each do |key, value|
          next if value.blank?
          user_profiles_filters << { match: { "user_profiles.customizations.#{key}" => value } }
        end

        { nested: { path: 'user_profiles', query: { bool: { must: user_profiles_filters } } } }
      end

    end

    def build_profile_query(profile)
      { nested: { path: 'user_profiles', query: { bool: { must: Elastic::QueryBuilder::UserProfileBuilder.build(@query, profile: profile) } } } }
    end
  end
end
