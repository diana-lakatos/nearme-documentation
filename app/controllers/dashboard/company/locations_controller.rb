class Dashboard::Company::LocationsController < Dashboard::Company::BaseController
  before_filter :find_location, except: [:new, :create]

  def new
    @location = @company.locations.build
    @location.administrator_id = current_user.id if current_user.is_location_administrator?
    render partial: 'form'
  end

  def create
    @location = @company.locations.build(location_params)
    if @location.save
      flash[:success] = t('flash_messages.manage.locations.space_added')
      event_tracker.created_a_location(@location, via: 'dashboard')
      event_tracker.updated_profile_information(current_user)
    else
      render partial: 'form'
    end
  end

  def edit
    render partial: 'form'
  end

  def update
    @location.assign_attributes(location_params)
    if @location.save
      flash[:success] = t('flash_messages.dashboard.locations.updated')
    else
      render partial: 'form'
    end
  end

  def destroy
    if @location.destroy
      event_tracker.updated_profile_information(current_user)
      event_tracker.deleted_a_location(@location)
      @location.listings.each { |listing| event_tracker.deleted_a_listing(listing) }
      flash[:deleted] = t('flash_messages.manage.locations.space_deleted', name: @location.name)
    else
      flash[:error] = t('flash_messages.manage.locations.space_not_deleted', name: @location.name)
    end
  end

  private

  def find_location
    @location = @company.locations.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    raise Location::NotFound
  end

  def location_params
    params.require(:location).permit(secured_params.location)
  end
end
