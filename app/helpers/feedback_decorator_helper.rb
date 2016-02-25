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
      h.link_to(h.image_tag(feedback_object.listing.photos.rank(:position).first.image_url(version)), feedback_object.listing.decorate.show_path)
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
