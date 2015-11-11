class Dashboard::AssetsController < Dashboard::BaseController
  before_filter :get_proper_hash, only: :create

  protected

  def get_proper_hash
    # we came from list your space flow
    if params[:listing]
      @listing_params = params[:listing]
      @listing = current_user.listings.find(params[:listing][:id]) if params[:listing][:id].present?
    elsif params[:transactable]
      @listing_params = params[:transactable]
      @listing = current_user.listings.find(params[:transactable][:id]) if params[:transactable][:id].present?
    elsif params[:project]
      @listing_params = params[:project]
      @owner_type = "Project"
      @listing = current_user.projects.find(params[:project][:id]) if params[:project][:id].present?
    elsif params[:user]
      @listing_params = params[:user][:companies_attributes]["0"][:locations_attributes]["0"][:listings_attributes]["0"]
      @listing = Transactable.find(@listing_params[:id]) if @listing_params[:id]
      # we came from dashboard
    end
  end

end
