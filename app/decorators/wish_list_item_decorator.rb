class WishListItemDecorator < Draper::Decorator
  include Draper::LazyHelpers

  delegate_all

  def image_url
    if wishlistable.try(:images)
      wishlistable.images.empty? ? no_image : asset_url(wishlistable.images.first.image_url)
    else
      wishlistable.has_photos? ? wishlistable.photos_metadata[0][:golden] : no_image
    end
  end

  def price
    if wishlistable.try(:price)
      number_to_currency_symbol wishlistable.currency, wishlistable.price
    else
      wishlistable.address
    end
  end

  def company_name
    object.wishlistable.company.name
  end

  def polymorphic_wishlistable_path
    if wishlistable.is_a?(Transactable)
      wishlistable.decorate.show_path
    elsif wishlistable.is_a?(Location)
      wishlistable.listings.searchable.first.try(:decorate).try(:show_path)
    elsif wishlistable.is_a?(Spree::Product)
      product_path(wishlistable)
    end
  end

  private

  def wishlistable
    object.wishlistable
  end

  def no_image
    asset_url 'placeholders/895x554.gif'
  end
end

