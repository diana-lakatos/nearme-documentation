module WishListItemsHelper

  def polymorphic_wishlistable_path(wishlistable)
    if wishlistable.is_a?(Transactable)
      transactable_type_location_listing_path(wishlistable.transactable_type, wishlistable.location, wishlistable)
    else
      polymorphic_path(wishlistable)
    end
  end

end

