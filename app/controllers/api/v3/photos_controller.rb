module Api
  class V3::PhotosController < BaseController
    before_filter :get_proper_hash, only: :create

    def create
      photos = @listing_params[:photos_attributes]["0"][:image].map do |image|
        photo = Photo.new
        photo.owner = @owner
        photo.owner_type ||= @owner_type
        photo.image = image
        photo.creator_id = current_user.id
        photo.save
        photo
      end
      render json: { data: { photo_ids: photos.map(&:id) } }
    end

    protected

    def get_proper_hash
      # we came from list your space flow
      if params[:listing]
        @listing_params = params[:listing]
        @listing = current_user.listings.find(params[:listing][:id]) if params[:listing][:id].present?
      elsif params[:offer]
        @listing_params = params[:offer]
        @listing = current_user.offers.find(params[:offer][:id]) if params[:offer][:id].present?
      elsif params[:transactable]
        @listing_params = params[:transactable]
        @listing = current_user.listings.find_by_id(params[:transactable][:id]) if params[:transactable][:id].present?
        @listing = current_user.created_listings.find(params[:transactable][:id]) if @listing.blank? && params[:transactable][:id].present?
        @owner = @listing
        @owner_type = 'Transactable'
      elsif params[:group]
        @listing_params = params[:group]
        @owner_type = "Group"
        if params[:group][:id].present?
          @listing = current_user.moderated_groups.find(params[:group][:id])
          @owner = @listing
        end
      elsif params[:user]
        if params[:user][:companies_attributes]["0"][:locations_attributes]
          @listing_params = params[:user][:companies_attributes]["0"][:locations_attributes]["0"][:listings_attributes]["0"]
          @listing = Transactable.find(@listing_params[:id]) if @listing_params[:id]
        else
          @listing_params = params[:user][:companies_attributes]["0"][:offers_attributes]["0"]
          @listing = current_user.offers.find(@listing_params[:id]) if @listing_params[:id].present?
        end
        # we came from dashboard
      end
    end

  end
end

