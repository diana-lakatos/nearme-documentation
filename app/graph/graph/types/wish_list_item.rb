# frozen_string_literal: true
module Graph
  module Types
    WishListItem = GraphQL::ObjectType.define do
      name 'WishListItem'
      global_id_field :id

      field :id, !types.ID
      field :name, types.String
      field :type, types.String
      field :image_url, types.String
      field :wishlistable_id, types.ID
    end
  end
end
