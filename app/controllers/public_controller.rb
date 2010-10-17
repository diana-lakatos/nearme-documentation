class PublicController < ApplicationController

  def index
    @featured = Workplace.featured
  end

end
