class SpaceWizardController < ApplicationController
  before_filter :redirect_to_tt_version_list, only: [:list]
  before_filter :redirect_to_tt_version_new, only: [:new]

  def new
  end

  def list
  end

  def destroy_photo
    @photo = Photo.find(params[:id])
    if can_delete_photo?(@photo, current_user) && @photo.destroy
      render text: { success: true, id: @photo.id }, content_type: 'text/plain'
    else
      render text: { errors: @photo.errors.full_messages }, status: 422, content_type: 'text/plain'
    end
  end

  private

  def redirect_to_tt_version_new
    redirect_to transactable_type_new_space_wizard_path(TransactableType.first)
  end

  def redirect_to_tt_version_list
    redirect_to transactable_type_space_wizard_list_path(TransactableType.first)
  end

  def can_delete_photo?(photo, user)
    return true if photo.creator == user                         # if the user created the photo
    return true if photo.listing.present? && photo.listing.administrator == user    # if the user is an admin of the photos content
    return true if user.present? && user.companies.any? { |c| c.listings.include?(photo.listing) } # if the photo content is a listing and belongs to one of the companies of the user
    false
  end
end
