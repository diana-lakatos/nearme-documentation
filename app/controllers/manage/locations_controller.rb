class Manage::LocationsController < Manage::BaseController
  before_filter :redirect_if_draft_listing
  before_filter :find_company
  before_filter :redirect_if_no_company
  before_filter :set_locations_scope
  before_filter :find_location, :except => [:index, :new, :create]

  def index
    @locations = @locations_scope.all
    event_tracker.track_event_within_email(current_user, request) if params[:track_email_event]
  end

  def new
    @location = @company.locations.build
    @location.administrator_id = current_user.id if current_user.is_location_administrator? 
    AvailabilityRule.default_template.apply(@location)
  end

  def create
    @location = @company.locations.build(params[:location])

    if @location.save
      flash[:success] = t('flash_messages.manage.locations.space_added')
      event_tracker.created_a_location(@location , { via: 'dashboard' })
      event_tracker.updated_profile_information(current_user)
      redirect_to manage_locations_path
    else
      render :new
    end
  end

  def show
    redirect_to edit_manage_location_path(@location)
  end

  def edit
  end

  def update
    @location.attributes = params[:location]

    if @location.save
      flash[:success] = t('flash_messages.manage.locations.space_updated')
      redirect_to manage_locations_path
    else
      render :edit
    end
  end

  def destroy
    if @location.destroy
      event_tracker.updated_profile_information(current_user)
      flash[:deleted] = t('flash_messages.manage.locations.space_deleted', name: @location.name)
    else
      flash[:error] = t('flash_messages.manage.locations.space_not_deleted', name: @location.name)
    end
    redirect_to manage_locations_path
  end

  private

  def redirect_if_draft_listing
    redirect_to new_space_wizard_url if current_user.listings.draft.any?
  end

  def find_location
    @location = @locations_scope.find(params[:id])
  end

  def find_company
    @company = current_user.companies.first
  end

  def redirect_if_no_company
    unless @company
      flash[:warning] = t('flash_messages.dashboard.add_your_company')
      redirect_to new_space_wizard_url
    end
  end

end
