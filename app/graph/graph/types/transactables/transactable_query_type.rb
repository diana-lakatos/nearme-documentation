# frozen_string_literal: true
module Graph
  module Types
    module Transactables
      TransactableQueryType = GraphQL::ObjectType.define do
        field :transactables do
          type !types[Types::Transactables::Transactable]
          argument :ids, types[types.ID], 'List of ids'
          argument :listing_type_id, types.ID
          argument :filters, types[Types::Transactables::TransactableFilterEnum]
          argument :take, types.Int
          argument :creator_id, types.ID

          resolve Graph::Resolvers::Transactables.new
        end

        field :transactable do
          type !Types::Transactables::Transactable
          argument :id, types.ID
          argument :slug, types.String, 'Slug of the transactable'
          argument :creator_id, types.ID
          resolve Graph::Resolvers::Transactable.new
        end
      end
    end
  end
end
