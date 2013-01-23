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
    @company = @user.companies.build
  end

  def submit_company
    @company = @user.companies.build
    @company.attributes = params[:company]

    if @company.save
      redirect_to space_wizard_space_url(:company_id => @company.id)
    else
      render :company
    end
  end

  def space
    @location = @company.locations.build
  end

  def submit_space
    @location = @company.locations.build
    @location.attributes = params[:location]
    @location.address_components_hash = params[:address_components] || {}

    if @location.save
      @location.build_address_components
      redirect_to space_wizard_desks_url(:company_id => @company.id, :space_id => @location.id)
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
    redirect_to [:edit, :manage, @space]
  end

  def find_user
    @user = current_user

    unless @user
      redirect_to new_space_wizard_url
    end
  end

  def find_company
    company_id = params[:company_id]
    @company = current_user.companies.find_by_id(company_id) if company_id

    unless @company
      redirect_to space_wizard_company_url
    end
  end

  def find_space
    space_id = params[:space_id]
    @space = @company.locations.find(space_id)

    unless @space
      redirect_to space_wizard_space_url
    end
  end

end
