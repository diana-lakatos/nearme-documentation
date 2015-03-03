class ReviewDecorator < Draper::Decorator
  include Draper::LazyHelpers
  include FeedbackDecoratorHelper
  
  delegate_all

  def date_format 
    if created_at.to_date == Time.zone.today
      I18n.t('decorators.review.today')
    else
      I18n.l(created_at, format: :day_month_year)
    end
  end

  def link_to_object
    if object.transactable_type.buy_sell?
      choose_link_by_object(seller: profile_path(feedback_object.product.administrator), 
        buyer: profile_path(feedback_object.order.user_id), product: product_path(feedback_object.product.id))
    else
      choose_link_by_object(seller: profile_path(feedback_object.creator_id), buyer: profile_path(feedback_object.owner_id),
        product: listing_path(feedback_object.transactable_id))
    end
  end

  def choose_link_by_object(links)
    case object.object
      when 'seller' then link_to_new_tab(I18n.t('helpers.reviews.user'), links[:seller])
      when 'buyer' then link_to_new_tab(I18n.t('helpers.reviews.user'), links[:buyer])
      when 'product' then link_to_new_tab(I18n.t('helpers.reviews.product'), links[:product])
    end
  end

  def link_to_new_tab(name, path)
    h.link_to name, path, target: "_blank"
  end

  def feedback_object
    object.reviewable
  end

  def link_to_seller_profile
    if reservation?
      h.link_to t('dashboard.reviews.feedback.view_seller_profile'), user_path(feedback_object.creator)
    else
      h.link_to t('dashboard.reviews.feedback.view_seller_profile'), user_path(feedback_object.product.administrator)
    end
  end

  def show_reviewable_info
    info = if params[:option] == 'reviews_left_by_seller' || params[:option] == 'reviews_left_by_buyer'
      if object.object == 'product'
        get_product_info
      else
        get_user_info
      end
    else
      own_info
    end

    reviewable_info(info)
  end

  private

  def reviewable_info(attrs)
    h.image_tag(attrs[:photo]) + content_tag(:p, attrs[:name])
  end

  def own_info
    user_info_for(user)
  end

  def get_user_info
    target_user = if reservation?
      object.object == 'seller' ? reviewable.creator : reviewable.owner
    else
      object.object == 'seller' ? reviewable.product.user : reviewable.order.user
    end

    user_info_for(target_user)
  end

  def user_info_for(target_user)
    {photo: target_user.avatar_url, name: target_user.first_name}
  end

  def info_for_reservation
    {photo: reservation_photo, name: reviewable.listing.try(:name)}
  end

  def info_for_line_item
    {photo: line_item_photo, name: reviewable.product.try(:name)}
  end

  def reservation_photo
    if reviewable.listing && reviewable.listing.has_photos?
      reviewable.listing.photos.first.image_url(:medium)
    else
      default_item_photo
    end
  end

  def line_item_photo
    if reviewable.product && reviewable.product.variant_images.present?
      reviewable.product.variant_images.first.attachment_url
    else
      default_item_photo
    end
  end

  def default_item_photo
    "ratings/reviews-placeholder.png"
  end

  def get_product_info
    reservation? ? info_for_reservation : info_for_line_item
  end
end