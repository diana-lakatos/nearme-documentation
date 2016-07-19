module FeedbackDecoratorHelper
  def review_title
    if reservation?
      feedback_object.transactable.try(:name)
    elsif bid?
      feedback_object.offer.try(:name)
    elsif line_item?
      feedback_object.line_item_source.try(:name)
    end
  end

  def order_image
    version = :space_listing

    if reservation? && feedback_object.transactable && feedback_object.transactable.has_photos?
      h.link_to(h.image_tag(feedback_object.transactable.photos.rank(:position).first.image_url(version)), feedback_object.transactable.decorate.show_path)
    elsif line_item? && feedback_object.line_item_source && feedback_object.line_item_source.has_photos?
      h.image_tag feedback_object.line_item_source.photos.rank(:position).first.image_url(version)
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
        user = feedback_object.transactable.creator
      else
        user = feedback_object.owner
      end
    elsif line_item?
      if target == RatingConstants::HOST
        user = feedback_object.line_item_source.creator
      else
        user = feedback_object.line_itemable.user
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
    feedback_object.is_a?(LineItem)
  end

  def bid?
    feedback_object.is_a?(Bid)
  end
end
