class ListingsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :index]
  before_filter :find_listing, :only => [:show, :edit, :update, :destroy]
  before_filter :authorize_editing!, :only => [:edit, :update, :destroy]
  before_filter :authorize_viewing!, :only => :show

  def index
    organizations = current_user ? current_user.organizations : []
    @listings = Listing.latest.with_organizations(organizations).paginate :page => params[:page]
  end

  def new
    @listing = current_user.listings.build(:quantity => 1, :confirm_reservations => false)
  end

  def create
    creator_id = nil;
    if(current_user.admin?)
      creator_id = params[:listing][:creator_id]
    end
    params[:listing].delete(:creator_id)
    @listing = current_user.listings.build(params[:listing])
    @listing.creator_id = creator_id if current_user.admin? and creator_id
    if @listing.save
      redirect_to @listing
    else
      render :new
    end
  end

  def show
    @listing = Listing.find(params[:id])
    @location = @listing.location
    @feeds = @listing.feeds.latest.limit(5)
  end

  def edit

  end

  def update
    @listing.creator_id = params[:listing][:creator_id] if current_user.admin?
    params[:listing].delete(:creator_id)
    if @listing.update_attributes(params[:listing])
      redirect_to @listing
    else
      raise @listing.availability_rules.map(&:day).inspect
      render :edit
    end
  end

  def destroy
    redirect_to @listing, :notice => "Permission Denied" unless current_user.admin?
    @listing.destroy
    redirect_to :root, :notice => "Destroyed :("
  end

  protected

  def find_listing
    @listing = Listing.find(params[:id])
  end

  def authorize_editing!
    redirect_to :root, :alert => "Could not find listing" unless @listing && @listing.created_by?(current_user)
  end

  def authorize_viewing!
    if @listing.required_organizations.any?
      unless current_user && current_user.may_view?(@listing)
        redirect_to listings_path, :alert => "Sorry, you don't have permission to view that"
      end
    end
  end
end
