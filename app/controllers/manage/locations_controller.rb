class Manage::LocationsController < Manage::BaseController
  before_filter :find_company
  before_filter :redirect_if_no_company
  before_filter :find_location, :except => [:index, :new, :create, :data_import]
  before_filter :redirect_if_not_admin, :only => :data_import

  def data_import
    @locations = Instance.find_by_name('PBCenter').locations
    render :index
  end

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
      flash[:success] = "Great, your new Space has been added!"
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
      flash[:success] = "Great, your Space has been updated!"
      redirect_to manage_locations_path
    else
      render :edit
    end
  end

  def destroy
    if @location.destroy
      flash[:deleted] = "You've deleted #{@location.name}"
    else
      flash[:error] = "We couldn't delete #{@location.name}"
    end
    redirect_to manage_locations_path
  end

  private

  def find_location
    if current_user.admin?
      @location = Location.find(params[:id])
    else
      @location = current_user.locations.find(params[:id])
    end
  end

  def find_company
    @company = current_user.companies.first
  end

  def redirect_if_no_company
    unless @company
      flash[:warning] = "Please add your company first"
      redirect_to new_space_wizard_url
    end
  end

  def redirect_if_not_admin
    redirect_to root_path unless current_user.admin?
  end

end
