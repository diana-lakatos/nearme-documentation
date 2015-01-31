class Dashboard::ReviewsController < Dashboard::BaseController
  skip_before_filter :redirect_if_no_company

  def index
    @current_instance = platform_context.instance
    get_rating_systems
    get_reservations_for_owner_and_creator
    params[:tab] == 'completed' ? get_reviews : get_reservations
  end

  def create
    @review = current_user.reviews.build
    if @review.update(review_params)
      rating_answers_params.values.each do |rating_answer_param|
        @review.rating_answers.create(rating_answer_param)
      end
      render partial: 'create_comment_congratulations', status: 200
    else
      render json: error_response, status: 422
    end
  end

  def destroy
    @review = current_user.reviews.find(params[:id])
    @review.destroy
    flash[:success] = t('flash_messages.dashboard.reviews.review_deleted')
    redirect_to dashboard_reviews_path
  end

  def update
    @review = current_user.reviews.find(params[:id])
    if @review.update(review_params)
      rating_answers_params.values.each do |rating_answer_param|
        if rating_answer_param[:id]
          @review.rating_answers.update(rating_answer_param[:id], rating_answer_param.except(:id))
        else
          @review.rating_answers.create(rating_answer_param)
        end
      end
      render partial: 'create_comment_congratulations', status: 200
    else
      render json: error_response, status: 422
    end
  end


  private

  def exclude_reservations_by(type)
    collection = type == :buyer_ids ? @creator_reservations : @owner_reservations
    collection.where.not(id: reservation_ids_with_feedback[type])
  end

  def review_params
    params.require(:review).permit(secured_params.review)
  end

  def rating_answers_params
    params.permit(secured_params.rating_answers)[:rating_answers] || {}
  end

  def reservation_ids_with_feedback
    @reservation_ids_with_feedback ||= RatingConstants::FEEDBACK_TYPES.each_with_object({}) do |type, hash|
      hash["#{type}_ids".to_sym] = reviews_with_object(type).pluck(:reservation_id)
    end
  end

  def reviews_with_object(type)
    current_user.reviews.with_object(type)
  end

  def get_rating_systems
    @active_rating_systems = RatingSystem.includes(:rating_hints, :rating_questions).where(active: true)
    @buyer_rating_system = @active_rating_systems.find_by(subject:  @current_instance.lessee)
    @seller_rating_system = @active_rating_systems.find_by(subject:  @current_instance.lessor)
    @product_rating_system = @active_rating_systems.find_by(subject:  @current_instance.bookable_noun)
  end

  def get_reservations_for_owner_and_creator
    reviews_service = ReviewsService.new(params)
    reservations = Reservation.with_listing.past.confirmed.includes(listing: :transactable_type)
    @owner_reservations = reservations.where(owner_id: current_user.id).by_period(*reviews_service.filter_period)
    @creator_reservations = reservations.where(creator_id: current_user.id).by_period(*reviews_service.filter_period)
  end

  def get_reviews
    @seller_reviews = reviews_with_object('seller').by_reservations(@owner_reservations.pluck(:id))
    @product_reviews = reviews_with_object('product').by_reservations(@owner_reservations.pluck(:id))
    @buyer_reviews = reviews_with_object('buyer').by_reservations(@creator_reservations.pluck(:id))
  end

  def get_reservations
    @seller_reservations = exclude_reservations_by(:seller_ids)
    @product_reservations = exclude_reservations_by(:product_ids)
    @buyer_reservations = exclude_reservations_by(:buyer_ids)
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
end