# frozen_string_literal: true
module Graph
  module Types
    Collaboration = GraphQL::ObjectType.define do
      name 'Collaboration'
      global_id_field :id

      field :id, !types.ID
      field :transactable, Types::Transactable do
        resolve ->(obj, _arg, _ctx) { Resolvers::Transactables.decorate(obj.transactable) }
      end
    end
  end
end
