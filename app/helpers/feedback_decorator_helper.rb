module FeedbackDecoratorHelper
  def review_title
    if reservation?
      feedback_object.listing.try(:name)
    else
      feedback_object.product.try(:name)
    end
  end

  def order_image
    version = PlatformContext.current.instance.new_ui? ? :space_listing : :medium

    if reservation? && feedback_object.listing && feedback_object.listing.has_photos?
      h.link_to(h.image_tag(feedback_object.listing.photos.rank(:position).first.image_url(version)), h.transactable_type_location_listing_path(feedback_object.listing.transactable_type, feedback_object.listing.location, feedback_object.listing))
    elsif line_item? && feedback_object.product && feedback_object.product.variant_images.present?
      h.image_tag feedback_object.product.variant_images.first.image_url(version)
    else
      h.image_tag "placeholders/895x554.gif"
    end
  end

  def reservation?
    feedback_object.is_a?(Reservation)
  end

  def line_item?
    feedback_object.is_a?(Spree::LineItem)
  end
end
