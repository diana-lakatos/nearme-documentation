# frozen_string_literal: true
class ReviewDecorator < Draper::Decorator
  include Draper::LazyHelpers
  include FeedbackDecoratorHelper

  delegate_all

  def date_format
    if created_at.to_date == Time.zone.today
      I18n.t('decorators.review.today')
    else
      I18n.l(created_at.to_date, format: :short)
    end
  end

  def transactable_path
    if reviewable.respond_to?(:transactable_id)
      listing_path(reviewable.transactable_id)
    else
      listing_path(reviewable.line_item_source)
    end
  end

  def link_to_object
    return I18n.t('instance_admin.manage.reviews.index.missing') if reviewable.nil?

    case object.rating_system.try(:subject)
    when RatingConstants::HOST then link_to_new_tab(I18n.t('helpers.reviews.user'), profile_path(reviewable.seller_type_review_receiver))
    when RatingConstants::GUEST then link_to_new_tab(I18n.t('helpers.reviews.user'), profile_path(reviewable.buyer_type_review_receiver))
    when RatingConstants::TRANSACTABLE then link_to_new_tab(I18n.t('helpers.reviews.product'), transactable_path)
    end
  end

  def link_to_new_tab(name, path)
    h.link_to name, path, target: '_blank'
  end

  def link_to_user_profile
    if rating_system.subject == RatingConstants::GUEST
      link_to_buyer_profile
    else
      link_to_seller_profile
    end
  end

  def link_to_buyer_profile
    if reservation?
      h.link_to t('dashboard.reviews.feedback.view_guest_profile'), user_path(reviewable.owner)
    else
      if reviewable.order
        h.link_to t('dashboard.reviews.feedback.view_buyer_profile'), user_path(reviewable.order.user)
      elsif reviewable.line_itemable && reviewable.line_itemable.order
        h.link_to t('dashboard.reviews.feedback.view_buyer_profile'), user_path(reviewable.line_itemable.order.user)
      else
        ''
      end
    end
  end

  def link_to_seller_profile
    if reservation?
      h.link_to t('dashboard.reviews.feedback.view_host_profile'), user_path(reviewable.creator)
    else
      h.link_to t('dashboard.reviews.feedback.view_seller_profile'), user_path(reviewable.transactable.administrator)
    end
  end

  def show_reviewable_info
    info = if %w(reviews_left_by_seller reviews_left_by_buyer reviews_left_about_product).include? params[:option]
             if object.rating_system.try(:subject) == 'transactable'
               get_product_info
             else
               get_user_info
             end
           else
             own_info
    end

    reviewable_info(info)
  end

  def feedback_object
    object.reviewable
  end

  private

  def reviewable_info(attrs)
    h.image_tag(attrs[:photo]) + content_tag(:p, attrs[:name], class: 'name-info')
  end

  def own_info
    user_info_for(user)
  end

  def get_user_info
    user_info_for(object.subject == RatingConstants::HOST ? seller : buyer)
  end

  def user_info_for(target_user)
    { photo: target_user.avatar_url, name: target_user.first_name }
  end

  def object_photo
    if reservation? && reviewable.transactable && reviewable.transactable.has_photos?
      reviewable.transactable.photos.first.image_url(:medium)
    else
      default_item_photo
    end
  end

  def default_item_photo
    asset_url 'placeholders/895x554.gif'
  end

  def get_product_info
    { photo: object_photo, name: review_title }
  end
end
