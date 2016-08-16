class WishListItemDrop < BaseDrop
  include CurrencyHelper
  # Required when calling methods here included from drops
  # These end up being available in drops but there's nothing
  # we can do at this point about it and they're not actually
  # dangerous
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TagHelper

  def initialize(wish_list_item)
    @wish_list_item = wish_list_item
    @wishlistable = @wish_list_item.wishlistable
  end

  # Is the associated object present?
  def wishlistable_present?
    @wish_list_item.wishlistable.present?
  end

  # Path to the associated object
  def wishlistable_path
    polymorphic_wishlistable_path(@wishlistable)
  end

  def wishlistable_type
    @wishlistable.class.name.downcase
  end

  def wishlistable_id
    @wishlistable.id
  end

  # Name of the associated object
  def wishlistable_name
    @wishlistable.name
  end

  # Name of the associated company
  def company_name
    @wishlistable.try(:companies).try(:first).try(:name) || @wishlistable.company.name
  end

  # Price of the associated item, otherwise the address
  def price
    if @wishlistable.try(:price)
      number_to_currency_symbol @wishlistable.currency, @wishlistable.price
    else
      @wishlistable.try(:address)
    end
  end

  # Location of the wishlistable
  def wishlistable_location
    @wishlistable.try(:location)
  end

  def dashboard_wish_list_item_path
    routes.dashboard_wish_list_item_path(@wish_list_item)
  end

  # Path to the image of the item
  def image_url
    if @wishlistable.try(:avatar_url)
      @wishlistable.avatar_url(:big)
    elsif @wishlistable.try(:images)
      @wishlistable.images.empty? ? no_image : asset_url(@wishlistable.images.first.image_url)
    else
      @wishlistable.photos_metadata.any? ? @wishlistable.photos_metadata[0][:golden] : no_image
    end
  end

  def polymorphic_wishlistable_path(wishlistable)
    if @wishlistable.is_a?(Transactable)
      @wishlistable.decorate.show_path
    elsif @wishlistable.is_a?(Location)
      @wishlistable.listings.searchable.first.try(:decorate).try(:show_path)
    end
  end

  # Default item image
  def no_image
    asset_url 'placeholders/895x554.gif'
  end

end

