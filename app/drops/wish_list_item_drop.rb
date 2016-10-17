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

  # @return [Boolean] whether the associated object (wishlisted) is present
  def wishlistable_present?
    @wish_list_item.wishlistable.present?
  end

  # @return [String] path to the associated object (wishlisted object)
  def wishlistable_path
    polymorphic_wishlistable_path(@wishlistable)
  end

  # @return [Strinig] type (downcased class name) of the wishlisted object
  def wishlistable_type
    @wishlistable.class.name.downcase
  end

  # @return [Integer] numeric identifier of the wishlisted object
  def wishlistable_id
    @wishlistable.id
  end

  # @return [String] name of the associated object (wishlisted object)
  def wishlistable_name
    @wishlistable.name
  end

  # @return [String] name of the associated company (company to which the wishlisted object belongs)
  def company_name
    @wishlistable.try(:companies).try(:first).try(:name) || @wishlistable.company.name
  end

  # @return [String, nil] price of the associated wishlisted item, if present, otherwise the address
  #   of the associated wishlisted item
  def price
    if @wishlistable.try(:price)
      number_to_currency_symbol @wishlistable.currency, @wishlistable.price
    else
      @wishlistable.try(:address)
    end
  end

  # @return [Location, nil] location of the wishlistable
  def wishlistable_location
    @wishlistable.try(:location)
  end

  # @return [String] path to the wish list item in the dashboard
  def dashboard_wish_list_item_path
    routes.dashboard_wish_list_item_path(@wish_list_item)
  end

  # @return [String] URL to the image of the wishlisted item, or a placeholders if not present
  def image_url
    if @wishlistable.try(:avatar_url)
      @wishlistable.avatar_url(:big)
    elsif @wishlistable.try(:images)
      @wishlistable.images.empty? ? no_image : asset_url(@wishlistable.images.first.image_url)
    else
      @wishlistable.photos_metadata.any? ? @wishlistable.photos_metadata[0][:golden] : no_image
    end
  end

  # @return [String] path to the wishlisted item
  def polymorphic_wishlistable_path(_wishlistable)
    if @wishlistable.is_a?(Transactable)
      @wishlistable.decorate.show_path
    elsif @wishlistable.is_a?(Location)
      @wishlistable.listings.searchable.first.try(:decorate).try(:show_path)
    elsif @wishlistable.is_a?(User)
      @wishlistable.decorate.show_path
    end
  end

  # @return [String] URL to the default (placeholder) wishlisted item image
  def no_image
    asset_url 'placeholders/895x554.gif'
  end
end
