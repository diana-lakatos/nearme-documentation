class SpaceWizardController < ApplicationController

  def signup
    @user = User.new
  end

  def submit_signup
    @user = User.new(params[:user])

    if @user.save
      redirect_to signup_wizard_company_url
    else
      render :signup
    end
  end

  def company
  end

  def submit_company
  end

  def space
  end

  def submit_space
  end

  def desks
  end

  def submit_desks
  end

  def complete
  end

end
