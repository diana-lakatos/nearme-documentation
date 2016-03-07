class WishListItemDecorator < Draper::Decorator
  include Draper::LazyHelpers

  delegate_all

  def image_url
    if wishlistable.try(:images).present?
      asset_url(wishlistable.images.first.image_url)
    elsif wishlistable.try(:has_photos?)
      wishlistable.photos_metadata[0][:golden]
    elsif wishlistable.try(:photos).present?
      wishlistable.photos.first.image.url(:golden)
    else
      no_image
    end
  end

  def price
    if wishlistable.try(:price)
      number_to_currency_symbol wishlistable.currency, wishlistable.price
    else
      wishlistable.try(:address)
    end
  end

  def company_name
    object.wishlistable.company.try(:name)
  end

  def polymorphic_wishlistable_path
    if wishlistable.is_a?(Transactable)
      wishlistable.decorate.show_path
    else
      wishlistable
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

