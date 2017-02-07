# frozen_string_literal: true
module Graph
  module Types
    module Search
      LocationType = GraphQL::ObjectType.define do
        name 'SearchLocationType'
        description 'Location Type'

        field :id, !types.ID
        field :name, !types.String
      end
    end
  end
end
