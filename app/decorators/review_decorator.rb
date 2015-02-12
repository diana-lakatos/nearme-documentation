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
      choose_link_by_object(seller: profile_path(feedback_object.product.administrator_id), 
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
end