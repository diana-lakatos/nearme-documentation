module FeedbackDecoratorHelper
  def review_title
    if reservation?
      feedback_object.listing.try(:name)
    else
      feedback_object.product.try(:name)
    end
  end

  def order_image
    if reservation? && feedback_object.listing && feedback_object.listing.has_photos?
      h.image_tag feedback_object.listing.photos.last.image_url(:medium)
    elsif line_item? && feedback_object.product && feedback_object.product.variant_images.present?
      h.image_tag feedback_object.product.variant_images.first.attachment_url
    else
      h.image_tag "ratings/reviews-placeholder.png"
    end
  end

  def reservation?
    feedback_object.is_a?(Reservation)
  end

  def line_item?
    feedback_object.is_a?(Spree::LineItem)
  end
end
