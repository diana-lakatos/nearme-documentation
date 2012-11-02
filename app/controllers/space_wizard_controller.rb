class SpaceWizardController < ApplicationController

  before_filter :find_user, :except => [:new]
  before_filter :find_company, :except => [:new, :company, :submit_company]
  before_filter :find_space, :except => [:new, :company, :submit_company, :space, :submit_space]

  def new
    if current_user
      redirect_to space_wizard_company_url
    else
      redirect_to new_user_registration_url(:wizard => 'space')
    end
  end

  def company
    @company = @user.companies.first_or_initialize
  end

  def submit_company
    @company = @user.companies.first_or_initialize
    @company.attributes = params[:company]

    if @company.save
      wizard_session[:company_id] = @company.id
      redirect_to space_wizard_space_url
    else
      render :company
    end
  end

  def space
    @location = @company.locations.first_or_initialize
  end

  def submit_space
    @location = @company.locations.first_or_initialize
    @location.attributes = params[:location]

    if @location.save
      redirect_to space_wizard_desks_url
    else
      render :space
    end
  end

  def desks
  end

  def submit_desks
    @space.attributes = params[:location]

    if @space.save
      redirect_for_complete
    else
      render :desks
    end
  end

  private

  def redirect_for_complete
    flash[:notice] = "Great, your space has been set up!"

    # TODO: When Spaces (Locations) are the exposed public object change
    #       this.
    if @space.listings.any?
      redirect_to listing_url(@space.listings.first)
    else
      redirect_to dashboard_url
    end
  end

  def wizard_session
    session[:space_wizard] ||= {}
  end

  def find_user
    @user = current_user

    unless @user
      redirect_to new_space_wizard_url
    end
  end

  def find_company
    company_id = wizard_session[:company_id]
    @company = current_user.companies.find_by_id(company_id) if company_id

    unless @company
      redirect_to space_wizard_company_url
    end
  end

  def find_space
    @space = @company.locations.first

    unless @space
      redirect_to space_wizard_space_url
    end
  end

end
