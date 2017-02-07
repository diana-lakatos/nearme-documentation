# frozen_string_literal: true
module Graph
  module Types
    module Search
      Category = GraphQL::ObjectType.define do
        name 'SearchCategory'
        description 'Category for search'

        global_id_field :id

        field :id, !types.ID
        field :name, !types.String
        field :translated_name, !types.String
        field :path, !types.String
        field :category_options, !types[types[types.String]] do
          resolve ->(obj, _args, _ctx) {
            obj.children.inject([]) { |options, c| options << [c.id, c.translated_name] }
          }
        end
      end
    end
  end
end
