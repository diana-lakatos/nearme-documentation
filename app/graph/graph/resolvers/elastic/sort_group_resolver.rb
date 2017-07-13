# frozen_string_literal: true
module Graph
  module Resolvers
    module Elastic
      class SortGroupResolver < BaseResolver
        private

        def resolve
          resolve_each_argument do |argument|
            SortItemResolver.new.call(self, argument, ctx)
          end
        end
      end

      class SortItemResolver < BaseResolver
        private

        def resolve
          resolve_argument :key do |value, node|
            { sort: { sort_field_name(value) => { order: node[:order] } } }
          end

          resolve_argument :profile_key do |value, node|
            {
              sort: {
                "user_profiles.#{value}" => {
                  order: node[:order],
                  nested_path: 'user_profiles',
                  nested_filter: {
                    term: { 'user_profiles.profile_type' => node[:profile_type] }
                  }
                }
              }
            }
          end
        end

        def sort_field_name(value)
          value =~ /properties\./ && "#{value}.raw" || value
        end
      end
    end
  end
end
