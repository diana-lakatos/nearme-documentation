# frozen_string_literal: true
module Graph
  module Types
    WishListItem = GraphQL::ObjectType.define do
      name 'WishListItem'
      global_id_field :id

      field :id, !types.ID
      field :wishlistable, Types::Wishlistable do
        resolve lambda { |item, _, ctx|
          case item.wishlistable_type.downcase
          when ::User.to_s.downcase
            Graph::Resolvers::User.new.call(nil, { id: item.wishlistable_id }, ctx)
          else
            item.wishlistable
          end
        }
      end
    end
  end
end
