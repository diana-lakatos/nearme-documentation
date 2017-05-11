module Elastic
  module QueryBuilder
    class SortingOptions
      def initialize(query)
        @query = query
      end

      def prepare
        return default_sort if @query[:sort].blank?

        @query[:sort]
          .split(',')
          .compact
          .map { |option| SortOption.new(option, query: @query) }
          .map(&:to_h)
          .each_with_object({}) { |field, sort| sort.merge!(field.to_h) }
      end

      private

      def default_sort
        { sort: ['_score'] }
      end

      class SortOption
        def initialize(source, query: {})
          @source = source
          @query = query
        end

        def to_h
          case type
          when 'custom_attribute'
            NestedSort.new(name: name, order: order, profile_type: 'seller')
          when 'user_profiles'
            NestedSort.new(name: name, order: order, profile_type: profile_name)
          when 'transactable'
            ChildFieldSort.new(name: name, order: order)
          when 'location'
            sort_by_location || default_sort
          when 'relevance'
            default_sort
          else
            SimpleSort.new(name: name, order: order)
          end
        end

        private

        def sort_by_location
          return unless @query.dig(:location, :lat).present?

          GeoSort.new(name: 'geo_location', location: @query[:location], order: order)
        end

        def default_sort
          SimpleSort.new(name: '_score', order: order)
        end

        def field
          @field ||= @source.match(/([a-zA-Z\.\_\-]*)_(asc|desc)/) || [@source, @source, 'asc']
        end

        def order
          field[2]
        end

        def name
          field[1].split('.').last
        end

        def type
          field[1].split('.').first
        end

        def profile_name
          field[1].split('.')[1]
        end

        def body
          {
            sort: {
              name => order
            }
          }
        end

        class GeoSort
          def initialize(name:, location:, order: 'asc')
            @name = name
            @order = order
            @location = location
          end

          def to_h
            { sort: [body] }
          end

          private

          def body
            {
              _geo_distance: {
                @name => @location,
                order: @order,
                distance_type: 'plane'
              }
            }
          end
        end

        class SimpleSort
          def initialize(name:, order:)
            @name = name
            @order = order
          end

          def to_h
            { sort: [{ @name => @order }] }
          end
        end

        class ChildFieldSort
          SCORE_MODE = 'max'.freeze

          def initialize(name:, order:, type: 'transactable')
            @name = name
            @order = order
            @type = type
          end

          def to_h
            {
              query: { bool: { must: [query_has_child] } },
              sort: [{ '_score' => @order }]
            }
          end

          private

          def query_has_child
            {
              has_child: {
                inner_hits: { _source: '*' },
                type: @type,
                score_mode: SCORE_MODE,
                query: {
                  function_score: script_score
                }
              }
            }
          end

          def script_score
            {
              script_score: {
                script: format('_score * doc["%s"].values[0]', @name)
              }
            }
          end
        end

        class NestedSort
          def initialize(name:, order:, profile_type:)
            @name = name
            @order = order
            @profile_type = profile_type
          end

          def to_h
            { sort: [{ "#{path}.properties.#{@name}" => body }] }
          end

          def body
            {
              order: @order,
              nested_path: path,
              nested_filter: {
                term: {
                  "#{path}.profile_type" => @profile_type
                }
              }
            }
          end

          def path
            'user_profiles'
          end
        end
      end
    end
  end
end
