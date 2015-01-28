class InstanceAdmin::Manage::ReviewsController < InstanceAdmin::Manage::BaseController
  def index
    reviews_service = ReviewsService.new(params)
    @reviews = reviews_service.get_reviews.includes(:reservation)
    @transactable_types = TransactableType.all

    respond_to do |format|
      format.html { @reviews = @reviews.paginate(:page => params[:page], :per_page => Review::PER_PAGE) }
      format.csv do
        csv_file = reviews_service.generate_csv_for @reviews
        send_data csv_file
      end
    end
  end
end