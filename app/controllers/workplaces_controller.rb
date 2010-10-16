class WorkplacesController < ApplicationController
  before_filter :require_user
  def new
    @workplace = current_user.workplaces.build(:maximum_desks => 1, :confirm_bookings => false)
  end

  def create
    @workplace = current_user.workplaces.create(params[:workplace])
  end

end
