# frozen_string_literal: true
module Elastic
  module QueryBuilder
    # for local class requeirements of buildng
    # franco was a famous builder
    class Franco
      attr_reader :query

      def initialize(query = {})
        @query = query
      end

      def add(branch)
        @query.deep_merge!(branch) do |_key, old, new|
          Array(old) + Array(new)
        end
      end

      def to_h
        @query.reverse_merge(default)
      end

      private

      def default
        {
          query: {
            match_all: {
              boost: QueryBuilderBase::QUERY_BOOST
            }
          }
        }
      end
    end

    class UsersQueryBuilder < QueryBuilderBase
      def initialize(query,
                     searchable_custom_attributes: [],
                     query_searchable_attributes: [],
                     instance_profile_types: PlatformContext.current.instance.instance_profile_types.searchable)
        @query = query

        @searchable_custom_attributes = searchable_custom_attributes
        @query_searchable_attributes = query_searchable_attributes
        @instance_profile_types = instance_profile_types

        @filters = []
        @not_filters = []
      end

      def regular_query
        Franco.new.tap do |builder|
          builder.add build_query_branch
          builder.add filter: { bool: { must: filters } }
          builder.add aggregations
          builder.add sorting
        end.to_h
      end

      def simple_query
        Franco.new.tap do |builder|
          builder.add _source: @query[:source]
          builder.add query: @query[:query]
          builder.add filter: { bool: { must: filters } }
          builder.add sorting
        end.to_h
      end

      private

      def filters
        @filters = []
        @filters.concat profiles_filters
        @filters.concat [geo_shape] if @query.dig(:location, :lat).present?
        @filters
      end

      def build_query_branch
        { query: { bool: { must: query_bool_conditions } } }
      end

      def query_bool_conditions
        [].tap do |conditions|
          conditions << simple_match_query if @query[:query].present?
          conditions << multi_match_query if @query_searchable_attributes.present?
          conditions << transactable_child
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
            profile_type: 'user_profiles',
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

      def sorting
        SortingOptions.new(@query).prepare
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

      def profiles_filters
        @instance_profile_types.map do |profile|
          build_profile_query(profile)
        end
      end

      def build_profile_query(profile)
        { nested: { path: 'user_profiles', query: { bool: { must: Elastic::QueryBuilder::UserProfileBuilder.build(@query, profile: profile) } } } }
      end

      def geo_shape
        {
          geo_shape: {
            geo_service_shape: {
              shape: {
                type: 'Point',
                coordinates: @query[:location].values_at(:lon, :lat)
              },
              relation: 'contains'
            }
          }
        }
      end

      def transactable_child
        HasTransactableChild.new(@query).to_h
      end

      class HasTransactableChild
        attr_reader :options

        def initialize(options)
          @options = options
        end

        def to_h
          {
            has_child: {
              type: 'transactable',
              query: {
                function_score: {
                  filter: { bool: { must: custom_attributes } }
                }
              }
            }
          }
        end

        def custom_attributes
          return [] unless options.dig(:transactable, :custom_attributes)

          options.dig(:transactable, :custom_attributes).map do |attribute, values|
            custom_attribute "custom_attributes.#{attribute}", values
          end
        end

        def custom_attribute(name, values)
          { terms: { name => values } }
        end
      end
    end
  end
end
