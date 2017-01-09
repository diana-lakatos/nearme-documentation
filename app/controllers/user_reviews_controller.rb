# frozen_string_literal: true
class UserReviewsController < ApplicationController
  def reviews_collections
    @user = User.find(params[:id])
    service = UserReviewsService.new(@user, params)
    @reviews = service.reviews_by_role.try(:includes, :rating_answers, rating_system: :rating_questions)
    @total_reviews = @reviews.length
    @reviews = @reviews.paginate(page: params[:reviews_page], per_page: 8, total_entries: @total_reviews)
    @average_rating = service.average_rating
    @max_rating = RatingConstants::MAX_RATING

    response.headers['Content-Type'] = 'application/json'
    render json: {
      template: render_to_string(partial: 'registrations/profile/tabs/reviews_content', formats: [:html], locals: { reviews: @reviews, rating_questions: @rating_questions }, layout: false),
      count: I18n.t('user_profile.labels.tabs.reviews', count: @total_reviews)
    }
  end
end
