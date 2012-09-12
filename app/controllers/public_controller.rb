class PublicController < ApplicationController

  def index
    @featured = Listing.featured
  end

  private

    def set_tabs
      @footer_tab = :home
    end

end
