module ReviewsHelper
  def active_completed_tab
    'active' if show_completed_feedback?
  end

  def active_uncompleted_tab
    'active' unless show_completed_feedback?
  end

  def rating_checked?(rating_value)
    params[:rating].try(:include?, rating_value.to_s)
  end

  def transactable_type_checked?(transactable_type_id)
    params[:transactable_type].try(:include?, transactable_type_id.to_s)
  end

  def date_param_value
    params[:date].presence
  end

  def period_selected?(period)
    params[:period] == period
  end

  def selected_date_value(date)
    Review::DATE_VALUES.each do |value|
      return I18n.t("instance_admin.manage.reviews.index.#{value}") if value == date
    end
  end

  def show_completed_feedback?
    params[:tab] == 'completed'
  end

  def array_of_last_years(number)
    ( number.years.ago.year..(Time.now.year - 1) ).to_a.reverse
  end

  def link_to_object(review)
    case review.object
      when 'seller' then link_to_new_tab(I18n.t('helpers.reviews.user'), profile_path(review.reservation.creator_id))
      when 'buyer' then link_to_new_tab(I18n.t('helpers.reviews.user'), profile_path(review.reservation.owner_id))
      when 'product' then link_to_new_tab(I18n.t('helpers.reviews.product'), listing_path(review.reservation.transactable_id))
    end
  end

  def link_to_new_tab(name, path)
    link_to name, path, target: "_blank"
  end

  def rating_stars(number)
    unselected_count = RatingConstants::MAX_RATING - number
    raw(content_tag(:i, nil, class: 'fa fa-star selected') * number +
      content_tag(:i, nil, class: 'fa fa-star') * unselected_count)
  end
end