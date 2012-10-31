class SpaceWizardController < ApplicationController

  before_filter :skip_signup_step_if_logged_in, :only => [:signup, :submit_signup]
  before_filter :find_user, :except => [:signup, :submit_signup]
  before_filter :find_company, :except => [:signup, :submit_signup, :company, :submit_company]
  before_filter :find_space, :except => [:signup, :submit_signup, :company, :submit_company, :space, :submit_space]

  def signup
    @user = User.new
  end

  def submit_signup
    @user = User.new(params[:user])

    if @user.save
      sign_in @user
      redirect_to space_wizard_company_url
    else
      render :signup
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
    @location = @company.locatoins.first_or_initialize
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
  end

  def complete
  end

  private

  def wizard_session
    session[:space_wizard] ||= {}
  end

  def skip_signup_step_if_logged_in
    if current_user
      redirect_to space_wizard_company_url
    end
  end

  def find_user
    @user = current_user

    unless @user
      redirect_to space_wizard_signup_url
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
    @space = @company.listings.first

    unless @space
      redirect_to space_wizard_space_url
    end
  end

end
