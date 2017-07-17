# frozen_string_literal: true
module Graph
  module Types
    class Collection
      FIRST_PAGE = 1

      def self.build(type)
        collections = ::Thread.current[:graph_collections] ||= {}
        collections[type] ||= build_type(type)
      end

      def self.build_type(type)
        GraphQL::ObjectType.define do
          name "#{type.name}Collection"
          field :total_entries, !types.Int
          field :total_pages, !types.Int
          field :current_page, !types.Int
          field :per_page, !types.Int
          field :has_next_page, !types.Boolean do
            resolve ->(obj, _args, _ctx) { obj.current_page < obj.total_pages }
          end
          field :has_previous_page, !types.Boolean do
            resolve ->(obj, _args, _ctx) { obj.current_page > FIRST_PAGE }
          end
          field :items, types[type], deprecation_reason: 'Use "results"' do
            resolve ->(obj, _, _) { obj }
          end
          field :results, types[type] do
            resolve ->(obj, _, _) { obj }
          end
        end
      end
    end
  end
end
