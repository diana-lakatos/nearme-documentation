module FeedbackDecoratorHelper
  def review_title
    feedback_object.transactable.try(:name)
  end

  def order_image
    version = :space_listing

    if reservation? && feedback_object.transactable && feedback_object.transactable.has_photos?
      h.link_to(h.image_tag(feedback_object.transactable.photos.rank(:position).first.image_url(version)), feedback_object.transactable.decorate.show_path)
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
    end

    user
  end

  def reservation?
    feedback_object.is_a?(Order)
  end

end
