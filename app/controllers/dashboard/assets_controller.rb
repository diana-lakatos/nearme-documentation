# frozen_string_literal: true
class Dashboard::AssetsController < Dashboard::BaseController
  before_action :get_proper_hash, only: :create

  protected

  def get_proper_hash
    # we came from list your space flow
    if params[:listing]
      @listing_params = params[:listing]
      @listing = current_user.listings.find(params[:listing][:id]) if params[:listing][:id].present?
    elsif params[:seller_attachment]
      @listing_params = { attachments_attributes: { '0' => params[:seller_attachment] } }
      @listing = current_user.transactables.find_by(id: params[:transactable_id]) || current_user.approved_transactables_collaborated.find_by(id: params[:transactable_id])
    elsif params[:offer]
      @listing_params = params[:offer]
      @listing = current_user.offers.find(params[:offer][:id]) if params[:offer][:id].present?
    elsif params[:transactable]
      @listing_params = params[:transactable]
      @listing = current_user.listings.find_by(id: params[:transactable][:id]) if params[:transactable][:id].present?
      @listing ||= current_user.approved_transactables_collaborated.find_by(id: params[:transactable][:id])
      @listing ||= current_user.created_listings.find(params[:transactable][:id]) if params[:transactable][:id].present?
      @owner = @listing
      @owner_type = 'Transactable'
    elsif params[:group]
      @listing_params = params[:group]
      @owner_type = 'Group'
      if params[:group][:id].present?
        @listing = current_user.moderated_groups.find(params[:group][:id])
        @owner = @listing
      end
    elsif params[:user]
      if params[:user][:companies_attributes]['0'][:locations_attributes]
        @listing_params = params[:user][:companies_attributes]['0'][:locations_attributes]['0'][:listings_attributes]['0']
        @listing = Transactable.find(@listing_params[:id]) if @listing_params[:id]
      else
        @listing_params = params[:user][:companies_attributes]['0'][:offers_attributes]['0']
        @listing = current_user.offers.find(@listing_params[:id]) if @listing_params[:id].present?
      end
      # we came from dashboard
    end
  end
end
