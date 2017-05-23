# frozen_string_literal: true
module Graph
  module Resolvers
    module Elastic
      class CustomAttributeGroupResolver < BaseResolver
        private

        def resolve
          resolve_each_argument do |argument|
            CustomAttributeResolver.new.call(self, argument, ctx)
          end
        end
      end

      class CustomAttributeResolver < BaseResolver
        private

        def resolve
          resolve_argument :value do |value, node|
            { filter: { bool: { must: [{ term: { custom_field_name(node[:name]) => value } }] } } }
          end

          resolve_argument :values do |value, node|
            { filter: { bool: { must: [{ terms: { custom_field_name(node[:name]) => value } }] } } }
          end
        end

        def custom_field_name(name)
          "custom_attributes.#{name}"
        end
      end

    end
  end
end
