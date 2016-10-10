class InstanceAdmin::Manage::ReviewsController < InstanceAdmin::Manage::BaseController
  def index
    @transactable_types = TransactableType.all

    @review_search_form = InstanceAdmin::ReviewSearchForm.new
    @review_search_form.validate(params)
    @reviews = SearchService.new(Review.select('reviews.*, users.name AS user_name').includes(:reviewable).joins(:user)).search(@review_search_form.to_search_params)

    respond_to do |format|
      format.html { @reviews = @reviews.paginate(page: params[:page]) }
      format.csv do
        csv_file = ReviewsService.generate_csv_for @reviews
        send_data csv_file
      end
    end
  end
end
