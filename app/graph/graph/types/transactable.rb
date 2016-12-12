# frozen_string_literal: true
module Graph
  module Types
    Transactable = GraphQL::ObjectType.define do
      name 'Transactable'
      description 'PPPP'

      global_id_field :id

      field :id, !types.ID
      field :name, !types.String
      field :description, !types.String
      field :show_path, !types.String
      field :cover_photo_url, !types.String
      field :summary, !types.String
      field :creator, !Types::User do
        resolve -> (obj, _args, _ctx) { UserDrop.new(obj.creator) }
      end
    end

    TransactableFilterEnum = GraphQL::EnumType.define do
      name 'TransactableFilter'
      description 'Available filters'
      value('ACTIVE', 'Active transactables')
      value('FEATURED', 'Featured transactables')
    end
  end
end
