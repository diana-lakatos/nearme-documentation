class V1::RatingsController < V1::BaseController
  before_filter :require_authentication
  before_filter :load_listing
  rescue_from ActiveRecord::RecordNotFound, with: :listing_not_found

  def show
    render json: rating_hash
  end

  def update
    raise DNM::MissingJSONData, "rating" if json_params["rating"].blank?

    @listing.rate_for_user json_params["rating"], current_user

    render json: rating_hash
  end

  def destroy
    rating = @listing.ratings.where(user_id: current_user.id).first
    rating.destroy if rating

    render json: rating_hash
  end

  protected

  def rating_hash
    { listing_id: @listing.id,
      user_id: current_user.id,
      rating: @listing.rating_for(current_user) }
  end

  def load_listing
    @listing = Listing.find params[:listing_id]
  end

  def listing_not_found
    # Kinda wish we could return a 404 here...
    e = DNM::Error.new "Missing Listing"
    e.errors << { resource: "Listing",
                  field:    "id",
                  code:     "missing" }
    render json: e.to_hash, status: e.status
  end

end
