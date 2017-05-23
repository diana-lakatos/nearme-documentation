# frozen_string_literal: true
module Graph
  module Resolvers
    module Elastic
      class CategoryGroupResolver < BaseResolver
        private

        def resolve
          resolve_each_argument do |argument|
            CategoryResolver.new.call(self, argument, ctx)
          end
        end
      end

      class CategoryResolver < BaseResolver
        private

        def resolve
          resolve_argument :ids do |values|
            {
              filter: { bool: { must: values.map { |value| { term: { categories: value } } } } }
            }
          end

          resolve_argument :values do |values, node|
            { filter: { bool: { must: [{ nested: {
              path: 'category_list',
              filter: { bool: { must: [
                { match: { 'category_list.name_of_root' => node[:name_of_root] } },
                { terms: { 'category_list.name' => values } }
              ] } }
            } }] } } }
          end
        end
      end
    end
  end
end
