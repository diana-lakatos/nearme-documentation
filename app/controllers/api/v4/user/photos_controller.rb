# frozen_string_literal: true
module Api
  class V4::User::PhotosController < Api::V4::User::BaseController
    before_action :validate_owner_type
    before_action :find_owner
    def create
      photos = @listing_params[:photos_attributes]['0'][:image].map do |image|
        photo = Photo.new
        photo.owner = @owner
        photo.owner_type ||= @owner_type
        photo.image = image
        photo.creator_id = current_user.id
        photo.save
        photo
      end
      render json: ApiSerializer.serialize_collection(photos, meta: { photos_ids: photos.map(&:id) })
    end

    protected

    def validate_owner_type
      raise NotImplementedError if Photo::VALID_OWNER_TYPES.include?(params[:owner_type])
    end
    def find_owner

      @owner = params[:owner_type].constantize.find_by(id: params[:owner_id])
    end
  end
end
