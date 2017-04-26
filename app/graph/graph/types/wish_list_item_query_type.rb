# frozen_string_literal: true
module Graph
  module Types
    WishListItemQueryType = GraphQL::ObjectType.define do
      field :wish_list_items do
        type !types[Types::WishListItem]
        argument :user_id, types.ID

        resolve lambda { |_obj, args, _ctx|
          ::WishListItem
            .joins(:wish_list)
            .merge(WishList.default.where(user_id: args[:user_id]))
        }
      end
    end
  end
end
