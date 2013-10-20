class ListingMessagesController < ApplicationController

  before_filter :authenticate_user!

  def index
    @threaded_listing_messages = current_user.threaded_listing_messages.reject do|key, listing_messages|
      listing_messages.last.archived_for?(current_user)
    end
  end

  def archived
    @threaded_listing_messages = current_user.threaded_listing_messages.select do |key, listing_messages|
      listing_messages.last.archived_for?(current_user)
    end
    render :index
  end

end
