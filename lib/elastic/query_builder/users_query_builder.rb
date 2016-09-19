module Elastic
  class QueryBuilder::UsersQueryBuilder < QueryBuilder

    def initialize(query, searchable_custom_attributes = nil, instance_profile_type)
      @query = query
      @searchable_custom_attributes = searchable_custom_attributes || []
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

        { simple_query_string: build_multi_match(@query[:query], @searchable_custom_attributes + searchable_main_attributes) }
      end
    end

    def searchable_main_attributes
      ['name^2', 'tags^10', 'company_name']
    end

    def sorting_options
      sorting_fields = []

      if @query[:sort].present?
        sorting_fields = @query[:sort].split(',').compact.map do |sort_option|
          if sort = sort_option.match(/([a-zA-Z\.\_\-]*)_(asc|desc)/)
            sort_column = "user_profiles.properties.#{sort[1].split('.').last}"
            {
              sort_column => {
                order: sort[2],
                nested_filter: {
                  term: {
                      'user_profiles.instance_profile_type_id': @instance_profile_type.id
                    }
                 }
                }
            }
          end
        end.compact
      end

      if sorting_fields.empty?
        return ['_score']
      end

      sorting_fields
    end

    def aggregations
      {}
    end

    def profiles_filters
      user_profiles_filters = [
        {
          match: {
            "user_profiles.enabled": true
          }
        },
        {
          match: {
            "user_profiles.instance_profile_type_id": @instance_profile_type.id
          }
        }
      ]

       if @query[:category_ids].present?
        category_ids = @query[:category_ids].split(',')
        if @instance_profile_type.category_search_type == 'OR'
          user_profiles_filters << {
            terms: {
              "user_profiles.category_ids": category_ids.map(&:to_i)
            }
          }
        elsif @instance_profile_type.category_search_type == 'AND'
          category_ids.each do |category|
            user_profiles_filters << {
              terms: {
                "user_profiles.category_ids": [category.to_i]
              }
            }
          end
        end
      end

      if @query[:lg_custom_attributes]
        @query[:lg_custom_attributes].each do |key, value|
          unless value.blank?
            user_profiles_filters <<
              {
                match: {
                  "user_profiles.properties.#{key}" => value.to_s.split(',').map{ |val| val.downcase }.join(' OR ')
                }
              }
          end
        end
      end

      if @instance_profile_type.search_only_enabled_profiles?
        initial_instance_filter + [
          {
            nested: {
              path: "user_profiles",
              query: {
                bool: {
                  must: user_profiles_filters
                }
              }
            }
          }
        ]
      else
        initial_instance_filter << {
          term: {
            instance_profile_type_ids: @instance_profile_type.id
          }
        }
      end
    end

    def initial_instance_filter
      [
        {
          term: {
            instance_id: @query[:instance_id]
          }
        }
      ]
    end

  end
end