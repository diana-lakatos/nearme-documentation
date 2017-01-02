# frozen_string_literal: true
module Graph
  module Types
    module Search
      Photo = GraphQL::ObjectType.define do
        name 'Photo'
        description 'Photo'

        global_id_field :id

        field :id, !types.ID
        field :space_listing, !types.String
      end
    end
  end
end
