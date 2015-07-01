class UserReviewsController < ApplicationController
  def reviews_collections
    @user = User.find(params[:id])
    service = UserReviewsService.new(@user, platform_context, params)
    @reviews = service.reviews_by_role.paginate(page: params[:reviews_page], per_page: 8)
    @rating_questions = service.rating_questions_by_role

    render json: {
      template: render_to_string(partial: 'registrations/profile/tabs/reviews_content', formats: [:html], locals: {reviews: @reviews, rating_questions: @rating_questions}, layout: false),
      count: I18n.t('user_profile.labels.tabs.reviews', count: @reviews.count)
    }
  end
end
