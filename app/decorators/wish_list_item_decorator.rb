class WishListItemDecorator < Draper::Decorator
  include Draper::LazyHelpers

  delegate_all

  def image_url
    if wishlistable.try(:images)
      return wishlistable.images.empty? ? no_image : asset_url(wishlistable.images.first.image_url)
    else
      return wishlistable.photos_metadata.any? ? wishlistable.photos_metadata[0][:golden] : no_image
    end
  end

  def price
    if wishlistable.try(:price)
      number_to_currency_symbol wishlistable.currency, wishlistable.price
    else
      wishlistable.address
    end
  end

  def company
    object.wishlistable.company.name
  end

  private

  def wishlistable
    object.wishlistable
  end

  def no_image
    asset_url 'placeholders/895x554.gif'
  end
end
