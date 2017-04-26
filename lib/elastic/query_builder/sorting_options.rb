module Elastic
  module QueryBuilder
    class SortingOptions
      def initialize(query)
        @query = query
      end

      def prepare
        return default_sort if @query[:sort].blank?
        return default_sort if @query[:sort] == 'relevance' # find and get rid of this crap

        @query[:sort]
          .split(',')
          .compact
          .map { |option| SortOption.new(option) }
          .select(&:valid?)
          .map(&:to_h)
          .each_with_object({}) { |field, sort| sort.merge!(field) }
      end

      private

      def default_sort
        { sort: ['_score'] }
      end

      class SortOption
        def initialize(source)
          @source = source
        end

        def to_h
          case type
          when 'custom_attribute'
            NestedSort.new(name: name, order: order, profile_type: 'seller').to_h
          when 'user_profiles'
            NestedSort.new(name: name, order: order, profile_type: profile_name).to_h
          when 'transactable'
            ChildFieldSort.new(name: name, order: order).to_h
          else
            SimpleSort.new(name: name, order: order).to_h
          end
        end

        def valid?
          field
        end

        def field
          @field ||= @source.match(/([a-zA-Z\.\_\-]*)_(asc|desc)/)
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

        class SimpleSort
          def initialize(name:, order:)
            @name = name
            @order = order
          end

          def to_h
            { sort: [{ @name => @order }] }
          end
        end

        class ChildFieldFilter
          SCORE_MODE = 'max'

          def initialize(name:, order:, type: 'transactable')
            @name = name
            @order = order
            @type = type
          end

          def to_h
            {
              query: {
                has_child: {
                  inner_hits: { _source: '*'},
                  type: @type,
                  score_mode: SCORE_MODE,
                  query: {
                    function_score: script_score
                  }
                }
              },
              sort: [{ '_score' => @order }]
            }
          end

          private

          def script_score
            {
              filter: { terms: { @name => terms } }
            }
          end
        end

        class ChildFieldSort
          SCORE_MODE = 'max'

          def initialize(name:, order:, type: 'transactable')
            @name = name
            @order = order
            @type = type
          end

          def to_h
            {
              query: {
                bool: {
                  must: [
                    has_child: {
                      inner_hits: { _source: '*' },
                      type: @type,
                      score_mode: SCORE_MODE,
                      query: {
                        function_score: script_score
                      }
                    }
                  ]
                }
              },
              sort: [{ '_score' => @order }]
            }
          end

          private

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
