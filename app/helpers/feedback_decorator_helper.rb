module FeedbackDecoratorHelper
  def review_title
    if reservation?
      feedback_object.listing.try(:name)
    elsif bid?
      feedback_object.offer.try(:name)
    else
      feedback_object.product.try(:name)
    end
  end

  def order_image
    version = :space_listing

    if reservation? && feedback_object.listing && feedback_object.listing.has_photos?
      h.link_to(h.image_tag(feedback_object.listing.photos.rank(:position).first.image_url(version)), feedback_object.listing.decorate.show_path)
    elsif line_item? && feedback_object.product && feedback_object.product.variant_images.present?
      h.image_tag feedback_object.product.variant_images.first.image_url(version)
    elsif bid? && feedback_object.offer  && feedback_object.offer.photos.any?
      h.link_to(h.image_tag(feedback_object.offer.photos.rank(:position).first.image_url(version)), h.offer_path(feedback_object.offer))
    else
      h.image_tag "placeholders/895x554.gif"
    end
  end

  def review_target_title(target)
    if target == RatingConstants::TRANSACTABLE
      return review_title
    end

    get_user_by_target(target).try(:name)
  end

  def review_target_image(target)
    if target == RatingConstants::TRANSACTABLE
      return order_image
    end

    user = get_user_by_target(target)

    if user
      h.image_tag user.avatar_url(:bigger)
    else
      h.image_tag "placeholders/895x554.gif"
    end
  end

  def get_user_by_target(target)
    user = nil

    if reservation?
      if target == RatingConstants::HOST
        user = feedback_object.listing.creator
      else
        user = feedback_object.owner
      end
    elsif line_item?
      if target == RatingConstants::HOST
        user = feedback_object.product.user
      else
        user = feedback_object.order.user
      end
    elsif bid?
      if target == RatingConstants::HOST
        user = feedback_object.offer.creator
      else
        user = feedback_object.user
      end
    end

    user
  end

  def reservation?
    feedback_object.is_a?(Reservation)
  end

  def line_item?
    feedback_object.is_a?(Spree::LineItem)
  end

  def bid?
    feedback_object.is_a?(Bid)
  end
end
