class ReviewDecorator < Draper::Decorator
  include Draper::LazyHelpers

  delegate_all

  def date_format 
    if created_at.to_date == Time.zone.today
      I18n.t('decorators.review.today')
    else
      I18n.l(created_at, format: :day_month_year)
    end
  end
end