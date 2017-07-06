# frozen_string_literal: true
module Graph
  module Resolvers
    class Users < Graph::Resolvers::Elastic::BaseResolver
      private

      def resolve
        document_types :user

        resolve_argument :take do |value|
          { size: value }
        end

        resolve_argument :ids do |value|
          { filter: { bool: { must: [{ ids: { values: value } }] } } }
        end

        resolve_argument :featured do |value|
          { filter: { bool: { must: [{ term: { featured: value } }] } } }
        end

        resolve_argument :slug do |value|
          { filter: { bool: { must: [{ term: { slug: value } }] } } }
        end

        resolve_argument :id do |value|
          { filter: { bool: { must: [{ term: { _id: value } }] } } }
        end

        resolve_argument :filters do |value|
          FiltersDeprecatedResolver.new.call(self, value, {})
        end
      end
    end

    class FiltersDeprecatedResolver < Graph::Resolvers::Elastic::BaseResolver
      private

      def resolve
        arguments.each do |field|
          add filter: { bool: { must: [{ term: { field.downcase => true } }] } }
        end
      end
    end
  end
end
