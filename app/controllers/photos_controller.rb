class PhotosController < ApplicationController
  before_filter :require_user
  before_filter :find_workplace

  def index
    @photos = @workplace.photos
    @photo ||= @photos.build
  end

  def create
    @photo = @workplace.photos.build(params[:photo])
    if @photo.save
      redirect_to :action => :index
    else
      index
      render :index
    end
  end

  protected

  def find_workplace
    @workplace = current_user.workplaces.find(params[:workplace_id])
  end
end
