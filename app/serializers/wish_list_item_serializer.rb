# frozen_string_literal: true
class WishListItemSerializer < ApplicationSerializer
  attributes :id, :wishlistable_id, :wishlistable_type
end
