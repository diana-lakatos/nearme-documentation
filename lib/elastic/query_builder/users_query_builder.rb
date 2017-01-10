# frozen_string_literal: true
module Elastic
  class QueryBuilder::UsersQueryBuilder < QueryBuilder
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
        size: query_limit,
        from: query_offset,
        fields: ['_id'],
        sort: sorting_options,
        query: match_query,
        filter: {
          bool: {
            must: @filters
          }
        }
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

    def aggregations
      {}
    end

    def profiles_filters
      user_profiles_filters = [
        {
          match: {
            'user_profiles.enabled': true
          }
        },
        {
          match: {
            'user_profiles.instance_profile_type_id': @instance_profile_type.id
          }
        }
      ]

      if @query[:category_ids].present?
        category_ids = @query[:category_ids].split(',')
        if @instance_profile_type.category_search_type == 'OR'
          user_profiles_filters << {
            terms: {
              'user_profiles.category_ids': category_ids.map(&:to_i)
            }
          }
        else
          category_ids.each do |category|
            user_profiles_filters << {
              terms: {
                'user_profiles.category_ids': [category.to_i]
              }
            }
          end
        end
     end

      @query[:lg_custom_attributes]&.each do |key, value|
        next if value.blank?
        attribute = key.match(/([a-zA-Z\.\_\-]*)_(gte|lte|gt|lt)/)
        if attribute
          user_profiles_filters <<
            {
              range: {
                "user_profiles.properties.#{attribute[1]}.raw" => {
                  attribute[2] => value.to_f
                }
              }
            }
        else
          user_profiles_filters <<
            {
              match: {
                "user_profiles.properties.#{key}.raw" => value.to_s.split(',').map(&:downcase).join(' OR ')
              }
            }
        end
      end

      @query[:lg_customizations]&.each do |key, value|
        next if value.blank?
        user_profiles_filters <<
          {
            match: {
              "user_profiles.customizations.#{key}.raw" => value.to_s.split(',').map(&:downcase).join(' OR ')
            }
          }
      end

      if @query[:availability_exceptions].present?
        from = to = nil
        from = Date.parse(@query[:availability_exceptions][:from]) if @query[:availability_exceptions][:from].present?
        to = Date.parse(@query[:availability_exceptions][:to]) if @query[:availability_exceptions][:to].present?

        if from.present? || to.present?
          hash = {
            not: {
              range: {
                "user_profiles.availability_exceptions" => {
                }
              }
            }
          }
          hash[:not][:range]["user_profiles.availability_exceptions"][:gte] = from if from.present?
          hash[:not][:range]["user_profiles.availability_exceptions"][:lte] = to if to.present?
          user_profiles_filters << hash
        end
      end

      if @instance_profile_type.search_only_enabled_profiles? || @instance_profile_type.admin_approval?
        [
          {
            nested: {
              path: 'user_profiles',
              query: {
                bool: {
                  must: user_profiles_filters
                }
              }
            }
          }
        ]
      else
        [
          {
            term: {
              instance_profile_type_ids: @instance_profile_type.id
            }
          }
        ]
      end
    end
  end
end
