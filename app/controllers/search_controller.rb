class SearchController < ApplicationController

  def index
    @query = params[:q]
    @within = params[:within].to_i # miles

    @workplaces = Workplace.search(@query, :within => @within)
  end

end
