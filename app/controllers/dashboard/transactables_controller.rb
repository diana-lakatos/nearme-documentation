class Dashboard::TransactablesController < Dashboard::BaseController
  before_filter :find_transactable_type
  before_filter :find_listing, :except => [:index, :new, :create]
  before_filter :find_locations
  before_filter :disable_unchecked_prices, :only => :update

  def index
    @transactables = @transactable_type.transactables.paginate(page: params[:page], per_page: 20)
  end

  def new
    @transactable = @transactable_type.transactables.build
    @transactable.availability_template_id = AvailabilityRule.default_template.id
    build_approval_request_for_object(@transactable) unless @transactable.is_trusted?
    @photos = current_user.photos.where(transactable_id: nil)
  end

  def create
    @transactable = @transactable_type.transactables.build(transactable_params)
    build_approval_request_for_object(@transactable) unless @transactable.is_trusted?
    if @transactable.save
      flash[:success] = t('flash_messages.manage.listings.desk_added', bookable_noun: platform_context.decorate.bookable_noun)
      event_tracker.created_a_listing(@transactable, { via: 'dashboard' })
      event_tracker.updated_profile_information(current_user)
      redirect_to dashboard_transactable_type_transactables_path(@transactable_type)
    else
      @photos = @transactable.photos
      render :new
    end
  end

  def show
    redirect_to edit_manage_location_listing_path(@location, @transactable)
  end

  def edit
    @photos = @transactable.photos
    build_approval_request_for_object(@transactable) unless @transactable.is_trusted?
    event_tracker.track_event_within_email(current_user, request) if params[:track_email_event]
  end

  def update
    @transactable.assign_attributes(transactable_params)
    build_approval_request_for_object(@transactable) unless @transactable.is_trusted?
    respond_to do |format|
      format.html {
        if @transactable.save
          flash[:success] = t('flash_messages.manage.listings.listing_updated')
          redirect_to dashboard_transactable_type_transactables_path(@transactable_type)
        else
          @photos = @transactable.photos
          render :edit
        end
      }
      format.json {
        if @transactable.save
          render :json => { :success => true }
        else
          render :json => { :errors => @transactable.errors.full_messages }, :status => 422
        end
      }
    end
  end

  def enable
    if @transactable.enable!
      render :json => { :success => true }
    else
      render :json => { :errors => @transactable.errors.full_messages }, :status => 422
    end
  end

  def disable
    if @transactable.disable!
      render :json => { :success => true }
    else
      render :json => { :errors => @transactable.errors.full_messages }, :status => 422
    end
  end

  def destroy
    @transactable.reservations.each do |r|
      r.perform_expiry!
    end
    @transactable.destroy
    event_tracker.updated_profile_information(current_user)
    event_tracker.deleted_a_listing(@transactable)
    flash[:deleted] = t('flash_messages.manage.listings.listing_deleted')
    redirect_to manage_locations_path
  end

  private

  # def find_location
  #   begin
  #     @location = if @transactable
  #                   @transactable.location
  #                 else
  #                   locations_scope.find(params[:location_id])
  #                 end
  #   rescue ActiveRecord::RecordNotFound
  #     raise Location::NotFound
  #   end
  # end

  def find_locations
    @locations = @company.locations
  end

  def find_listing
    begin
      @transactable = @transactable_type.transactables.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      raise Transactable::NotFound
    end
  end

  def disable_unchecked_prices
    Transactable::PRICE_TYPES.each do |price|
      if params[:transactable]["#{price}_price"].blank?
        @transactable.send("#{price}_price=", nil) if @transactable.respond_to?("#{price}_price_cents=")
      end
    end
  end

  def find_transactable_type
    @transactable_type = TransactableType.find(params[:transactable_type_id])
  end

  def transactable_params
    params.require(:transactable).permit(secured_params.transactable(@transactable_type))
  end
end
