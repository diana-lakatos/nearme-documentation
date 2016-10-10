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

  def show_completed_feedback?
    params[:tab] == 'completed'
  end

  def array_of_last_years(number)
    (number.years.ago.year..(Time.now.year - 1)).to_a.reverse
  end

  def rating_stars(number)
    unselected_count = RatingConstants::MAX_RATING - number
    raw(content_tag(:i, nil, class: 'fa fa-star selected') * number +
      content_tag(:i, nil, class: 'fa fa-star') * unselected_count)
  end
end
