class Dashboard::ReviewsController < Dashboard::BaseController
  def index
    completed_tab = params[:tab] == 'completed'
    @rating_systems = reviews_service.get_rating_systems
    @collections = reviews_service.get_reviews_collection(completed_tab)
  end

  def rate
    @status = 'uncompleted'
    @rating_systems = reviews_service.get_rating_systems
    @collections = reviews_service.get_reviews_collection(false)

    render action: :index
  end

  def completed
    @status = 'completed'
    @rating_systems = reviews_service.get_rating_systems
    @collections = reviews_service.get_reviews_collection(true)

    render action: :index
  end

  def create
    @review = current_user.reviews.build
    @review.transactable_type_id = reviews_service.get_transactable_type_id
    @review.rating_system_id = RatingSystem.find(params.delete(:rating_system_id)).id
    if @review.update(review_params)
      rating_answers_params.values.each do |rating_answer_param|
        @review.rating_answers.create!(rating_answer_param)
      end
      @review.recalculate_reviewable_average_rating
      render partial: 'create_comment_congratulations', status: 200
    else
      render json: error_response, status: 422
    end
  end

  def destroy
    @review = current_user.reviews.find(params[:id])
    @review.destroy
    @review.recalculate_reviewable_average_rating
    flash[:success] = t('flash_messages.dashboard.reviews.review_deleted')
    redirect_to completed_dashboard_reviews_path
  end

  def update
    @review = current_user.reviews.find(params[:id])
    @review.transactable_type_id = reviews_service.get_transactable_type_id

    if @review.update(review_params)
      rating_answers_params.values.each do |rating_answer_param|
        if rating_answer_param[:id]
          @review.rating_answers.update(rating_answer_param[:id], rating_answer_param.except(:id))
        else
          @review.rating_answers.create(rating_answer_param)
        end
      end
      @review.recalculate_reviewable_average_rating
      render partial: 'create_comment_congratulations', status: 200
    else
      render json: error_response, status: 422
    end
  end

  private

  def review_params
    params.require(:review).permit(secured_params.review)
  end

  def rating_answers_params
    params.permit(secured_params.rating_answers)[:rating_answers] || {}
  end

  def error_response
    errors = {}
    %i(rating comment).each do |field|
      errors.merge!(render_errors(field)) if @review.errors.messages[field].present?
    end
    errors
  end

  def render_errors(field)
    {
      "#{field}_error" => render_to_string(partial: "#{field}_error", layout: false,
                                           locals: { error: @review.errors.messages[field].map(&:capitalize).join(', ') })
    }
  end

  def reviews_service
    @reviews_service ||= ReviewsService.new(current_user, params)
  end
end
