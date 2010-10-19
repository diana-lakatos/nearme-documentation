class WorkplacesController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :index]
  before_filter :find_workplace, :only => [:edit, :update, :destroy]

  def index
    @workplaces = Workplace.latest.paginate :page => params[:page]
  end

  def new
    @workplace = current_user.workplaces.build(:maximum_desks => 1, :confirm_bookings => false)
  end

  def create
    @workplace = current_user.workplaces.build(params[:workplace])
    @workplace.creator_id = params[:workplace][:creator_id] if current_user.admin?
    debugger
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
    @workplace.creator_id = params[:workplace][:creator_id] if current_user.admin?
    if @workplace.update_attributes(params[:workplace])
      redirect_to @workplace
    else
      render :edit
    end
  end
  
  def destroy
    redirect_to @workplace, :notice => "Permission Denied" unless current_user.admin?
    @workplace.destroy
    redirect_to :root, :notice => "Destroyed :("
  end

  protected

  def find_workplace
    @workplace = Workplace.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @workplace.created_by?(current_user)
  rescue ActiveRecord::RecordNotFound
    redirect_to :root, :alert => "Could not find workplace"
  end

end
