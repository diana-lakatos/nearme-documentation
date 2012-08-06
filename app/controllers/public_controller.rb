class PublicController < ApplicationController

  def index
    @featured = Listing.featured
  end

end
