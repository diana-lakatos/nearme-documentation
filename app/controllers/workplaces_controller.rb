class WorkplacesController < ApplicationController
  before_filter :require_user, :except => [:show, :index]
  before_filter :find_workplace, :only => [:edit, :update]

  def index
    @workplaces = Workplace.latest.paginate :page => params[:page]
  end

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
    @feeds = @workplace.feeds.limit(5)
  end

  def edit

  end

  def update
    if @workplace.update_attributes(params[:workplace])
      redirect_to @workplace
    else
      render :edit
    end
  end

  protected

  def find_workplace
    @workplace = current_user.workplaces.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to :root, :alert => "Could not find workplace"
  end
end
