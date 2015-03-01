class Dashboard::ReviewsController < Dashboard::BaseController
  skip_before_filter :redirect_if_no_company, :redirect_unless_registration_completed

  def index
    @current_instance = platform_context.instance
    completed_tab = params[:tab] == 'completed'
    @rating_systems = reviews_service.get_rating_systems
    if @current_instance.buyable?
      @line_items = reviews_service.get_line_items_for_owner_and_creator
      @collections = completed_tab ? reviews_service.get_orders_reviews(@line_items) : reviews_service.get_orders(@line_items)
    else
      @reservations_for_owner_and_creator = reviews_service.get_reservations_for_owner_and_creator
      @collections = completed_tab ? reviews_service.get_reviews_by(@reservations_for_owner_and_creator) : reviews_service.get_reservations(@reservations_for_owner_and_creator)
    end
  end

  def create
    @review = current_user.reviews.build
    @review.transactable_type_id = reviews_service.get_transactable_type_id
    if @review.update(review_params)
      rating_answers_params.values.each do |rating_answer_param|
        @review.rating_answers.create(rating_answer_param)
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
    redirect_to dashboard_reviews_path
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
        locals: {error: @review.errors.messages[field].map(&:capitalize).join(', ')})
    }
  end

  def reviews_service
    @reviews_service ||= ReviewsService.new(current_user, platform_context.instance, params)
  end
end