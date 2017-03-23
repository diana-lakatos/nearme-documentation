# frozen_string_literal: true
module Graph
  module Types
    GroupCollaboration = GraphQL::ObjectType.define do
      name 'GroupCollaboration'
      global_id_field :id

      field :id, !types.ID
      field :group, Types::Group
    end
  end
end
