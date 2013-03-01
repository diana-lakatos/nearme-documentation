class V1::ListingsController < V1::BaseController

  skip_before_filter :verify_authenticity_token, :only => [:create, :update, :destroy]

  # Endpoints that require authentication
  before_filter :require_authentication,         only: [:create, :update, :destroy, :connections, :inquiry, :reservation, :share]
  before_filter :find_listing,                   only: [:update, :destroy]
  before_filter :validate_search_params!,        only: :search
  before_filter :validate_query_params!,         only: :query
  before_filter :validate_reservation_params!,   only: :reservation
  before_filter :validate_availability_params!,  only: :availability
  before_filter :validate_inquiry_params!,       only: :inquiry

  # Default error handler
  rescue_from ActiveRecord::RecordNotFound, with: :listing_not_found

  def list
    @listings = current_user.company(params[:location_id]).listings.select('id,name')
  end

  def create
    @listing = Listing.create(params[:listing])
    @listing.location_id = params["location_id"]
    if @listing.save
      render :json => {:success => true, :id => @listing.id}
    else
      logger.info("ERRORS:#{@listing.errors.full_messages}")
      render :json => { :errors => @listing.errors.full_messages }, :status => 422
    end
  end

  def update
    if params[:listing][:photos_attributes] == nil
      params[:listing].delete :photos_attributes
    end
    @listing.attributes = params[:listing]

    if @listing.save
      render :json => @listing, :root => false, :serializer => ListingWebSerializer
    else
      render :json => { :errors => @listing.errors.full_messages }, :status => 422
    end
  end

  def destroy
    if @listing.destroy
      render json: { success: true, id: @listing.id }
    else
      render :json => { :errors => @listing.errors.full_messages }, :status => 422
    end
  end

  def show
    render :json => Listing.find(params[:id])
  end

  # FIXME: same code in search/query? Can they be the same API endpoint?
  def search
    listings = Listing.search_from_api(json_params.merge(user: current_user))
    render :json => listings
  end

  def query
    listings = Listing.search_from_api(json_params.merge(user: current_user))
    render :json => listings
  end


  # Create a new reservation
  def reservation

    listing     = Listing.find(params[:id])
    reservation = listing.reserve!(current_user, @dates, @quantity, @assignees)

    # Render the newly created reservation
    render :json => reservation

  end


  # Retrieve the reservation availability for a listing
  def availability

    listing = Listing.find(params[:id])
    render :json => formatted_availability_for(listing, @dates)

  end


  def inquiry
    listing = Listing.find(params[:id])
    @message = json_params["query"]

    inquiry = listing.inquiry_from!(current_user, message: @message)
    InquiryMailer.inquiring_user_notification(inquiry).deliver!
    InquiryMailer.listing_creator_notification(inquiry).deliver!

    head :no_content
  end


  def share
    users = validate_share_params!
    listing = Listing.find(params[:id])
    message = json_params["query"]
    users.each do |user|
      ListingMailer.share(listing, user["email"], user["name"], current_user, message).deliver!
    end

    head :no_content
  end


  def patrons
    listing = Listing.find(params[:id])

    # Query for a list of seats
    seats = ReservationSeat.joins(
        :reservation_period => { :reservation => :listing }
    ).where(
        :listings => {:id => listing.id}
    )

    # Now extract the corresponding user IDs
    user_ids = seats.map { |seat| seat.user_id }.uniq

    # Ignore users that aren't DNM account holders
    user_ids = user_ids.reject { |id| id.blank? }

    # Remove the current user's ID
    user_ids.delete(current_user.id)

    # Perform a full user lookup and return
    patrons = User.includes().where(:id => user_ids)

    render json: formatted_patrons(listing, patrons)
  end


  # Return the user's connections associated with the listing
  def connections

    listing = Listing.find(params[:id])

    # List of users that the current user is connected to
    users = current_user.followed_users

    # Corresponding user ID list
    user_ids = users.map { |u| u.id }

    # Query for a list of seats for the given property, restricted to the user list above
    seats = ReservationSeat.joins(
        :reservation_period => { :reservation => :listing }
    ).where(
        :listings => {:id => listing.id},
        :user_id => user_ids
    )

    # Now extract the corresponding user IDs
    user_ids = seats.map { |seat| seat.user_id }.uniq

    # Remove the current user's ID
    user_ids.delete(current_user.id)

    # Perform a full user lookup
    patrons = User.includes().where(:id => user_ids)

    render json: formatted_patrons(listing, patrons)
  end


  ##
  ##
  protected

  # Formatted hash of patrons for a given listing
  def formatted_patrons(listing, patrons)

    {
      listing_id: listing.id,
      users: patrons.map { |p|
        {
          id: p.id,
          name: p.name,
          avatar: formatted_avatar(p)
        }
      }
    }
  end

  # Formatted hash of a User's avatar images
  def formatted_avatar(patron)

    return {} if patron.avatar.blank?
    {
        thumb_url:  "#{patron.avatar_url(:thumb)}",
        medium_url: "#{patron.avatar_url(:medium)}",
        large_url:  "#{patron.avatar_url(:large)}"
    }

  end


  def validate_search_params!
    raise DNM::MissingJSONData, "boundingbox" if json_params["boundingbox"].blank?
  end


  def validate_query_params!
    raise DNM::MissingJSONData, "query" if json_params["query"].blank?
  end


  # Validate the JSON POST for reserving a listing
  def validate_reservation_params!

    # Dates are required
    raise DNM::MissingJSONData, "dates" if json_params["dates"].blank?
    @dates = Array(json_params["dates"])
    begin
      @dates.map! { |d| Date.parse d }.sort!
    rescue
      raise DNM::InvalidJSONData, "dates"
    end

    # Dates cannot be in the past
    @dates.each { |date|
      raise DNM::InvalidJSONDate.new("dates") if date.past?
    }

    @email = json_params["email"]
    raise DNM::MissingJSONData, "email" if @email.blank?

    @quantity = json_params["quantity"]
    @assignees = json_params["assignees"]

    # Default for quantity
    if @quantity.blank?
      if @assignees.blank?
        @quantity = 1
      else

        # Ensure the quantity matches the number of assignees
        if @assignees.size != @quantity
          raise DNM::InvalidJSONData, "quantity"
        end

      end
    end

    # Check the list of assignees
    if not @assignees.blank?

      # Make sure each assignee has a name and email address
      @assignees.each { |user|
        raise DNM::MissingJSONData, "name"  if user["name"].blank?
        raise DNM::MissingJSONData, "email" if user["email"].blank?
      }

    end

  end

  def validate_availability_params!
    raise DNM::MissingJSONData, "dates" if json_params["dates"].blank?
    @dates = Array(json_params["dates"])
    @dates.map! { |d| Date.parse d }.sort!
  rescue
    raise DNM::InvalidJSONData, "dates"
  end

  def validate_inquiry_params!
    raise DNM::MissingJSONData, "message" if json_params["message"].blank?
  end

  def validate_share_params!
    users = json_params["to"]
    raise DNM::MissingJSONData, "to" if users.blank?
    users.each { |user|
      raise DNM::MissingJSONData, "name"  if user["name"].blank?
      raise DNM::MissingJSONData, "email" if user["email"].blank?
    }
  end

  def listing_not_found
    # Kinda wish we could return a 404 here...
    e = DNM::Error.new "Missing Listing"
    e.errors << { resource: "Listing",
                  field:    "id",
                  code:     "missing" }
    render json: e.to_hash, status: e.status
  end

  # Formatted listing availability record
  def formatted_availability_for(listing, dates)

    list = dates.map { |date|

      timestamp_start = date.to_time(:utc)
      timestamp_end = timestamp_start + 1.day - 1

      {
        start_at: timestamp_start,
        end_at: timestamp_end,
        available: listing.availability_for(date)
      }
    }

    {
        listing_id: listing.id,
        availability: list
    }
  end

  private
    def find_listing
      @listing = current_user.listings.find(params[:id])
    end
end
