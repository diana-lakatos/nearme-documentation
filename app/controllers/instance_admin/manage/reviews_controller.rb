class InstanceAdmin::Manage::ReviewsController < InstanceAdmin::Manage::BaseController
  def index
    reviews_service = ReviewsService.new(current_user, platform_context.instance, params)
    @reviews = reviews_service.get_reviews.includes(:reviewable)
    @transactable_types = TransactableType.all

    respond_to do |format|
      format.html { @reviews = @reviews.paginate(:page => params[:page]) }
      format.csv do
        csv_file = reviews_service.generate_csv_for @reviews
        send_data csv_file
      end
    end
  end
end
