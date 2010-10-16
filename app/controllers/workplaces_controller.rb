class WorkplacesController < ApplicationController

  before_filter :require_user, :except => [ :show ]

  def new
    @workplace = current_user.workplaces.build(:maximum_desks => 1, :confirm_bookings => false)
  end

  def create
    @workplace = current_user.workplaces.build(params[:workplace])
    if @workplace.save
      redirect_to @workplace
    else
      render :new
    end
  end
  
  def show
    @workplace = Workplace.find(params[:id])
  end

end
