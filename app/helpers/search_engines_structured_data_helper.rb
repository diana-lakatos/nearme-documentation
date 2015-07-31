module SearchEnginesStructuredDataHelper
  def product_structured_data
    if @product.present?
      return "
        <div class='hidden' itemscope itemtype='http://schema.org/Product' data-structured>
          <span itemprop='name'>#{@product.name}</span>
          <img itemprop='image' src='#{@product.first_image_url}' alt='#{@product.name}' />

          <span itemprop='description'>#{@product.description.present? ? @product.description : @product.name}</span>

          <span itemprop='aggregateRating' itemscope itemtype='http://schema.org/AggregateRating'>
            <span itemprop='ratingValue'>#{@product.reviews.count > 0 ? 0 : @product.try(:average_rating).try(:round)}</span>
            <span itemprop='reviewCount'>#{@product.reviews_count}</span>
          </span>

          <span itemprop='offers' itemscope itemtype='http://schema.org/Offer'>
            <meta itemprop='priceCurrency' content='#{current_instance.default_currency}' />
            <span itemprop='price'>#{@product.price.to_f > 0 ? @product.price.to_f : 0}</span>
          </span>
        </div>
      ".html_safe
    end
  end

  def transactable_structured_data
    if @listing.present?
      return "
        <div class='hidden' itemscope itemtype='http://schema.org/Product' data-structured>
          <span itemprop='name'>#{@listing.name}</span>
          <img itemprop='image' src='#{@listing.photos.first.try(:image).try(:url)}' alt='#{@listing.name}' />

          <span itemprop='description'>#{@listing.description.present? ? @listing.description : @listing.name}</span>

          <span itemprop='aggregateRating' itemscope itemtype='http://schema.org/AggregateRating'>
            <span itemprop='ratingValue'>#{@listing.reviews.count > 0 ? 0 : @listing.try(:average_rating).try(:round)}</span>
            <span itemprop='reviewCount'>#{@listing.reviews.count}</span>
          </span>
        </div>
      ".html_safe
    end
  end
end
