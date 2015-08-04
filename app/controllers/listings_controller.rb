class ListingsController < ApplicationController
  before_filter :find_listing, only: :occurrences

  def occurrences
    occurrences = @listing.next_available_occurrences(10, params)
    render json: occurrences, root: false
  end

  protected

  def find_listing
    @listing = Transactable.with_deleted.find(params[:id])
  end

end
