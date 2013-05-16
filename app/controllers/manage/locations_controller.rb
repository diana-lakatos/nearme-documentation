class Manage::LocationsController < Manage::BaseController
  before_filter :find_company
  before_filter :redirect_if_no_company
  before_filter :find_location, :except => [:index, :new, :create]

  def index
    @locations = current_user.locations
  end

  def new
    @location = @company.locations.build
    AvailabilityRule.default_template.apply(@location)
  end

  def create
    @location = @company.locations.build(params[:location])

    if @location.save
      flash['create green'] = "Great, your new Space has been added!"
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
      flash['create green'] = "Great, your Space has been updated!"
      redirect_to manage_locations_path
    else
      render :edit
    end
  end

  def destroy
    if @location.destroy
      flash['delete red'] = "You've deleted #{@location.name}"
    else
      flash['warning red'] = "We couldn't delete #{@location.name}"
    end
    redirect_to manage_locations_path
  end

  private

  def find_location
    @location = @company.locations.find(params[:id])
  end

  def find_company
    @company = current_user.companies.first
  end

  def redirect_if_no_company
    unless @company
      flash['warning orange'] = "Please add your company first"
      redirect_to new_space_wizard_url
    end
  end

end
