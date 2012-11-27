class Manage::CompaniesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_company, :except => [:index]

  def index
    redirect_to [:edit, :manage, current_user.companies.first]
  end

  def edit
  end

  def update
    @company.attributes = params[:company]

    if @company.save
      flash[:context_success] = "Great, your company details have been updated."
      redirect_to [:edit, :manage, @company]
    else
      render :edit
    end
  end

  private

  def find_company
    @company = current_user.companies.find(params[:id])
  end
end
