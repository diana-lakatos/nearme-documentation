class TagsController < ApplicationController
  def index
    if params[:q].nil?
      render json: [], root: false      
    else
      coerce_query_if_needed!
      tags = Tag.autocomplete(params[:q])
      
      render json: tags, root: false
    end
  end

  private

  def coerce_query_if_needed!
    # If we have a leading whitespace, we'd like to search for all terms.
    # This is a way to accomplish combo-box-like feature.

    params[:q].sub!(" ", "") if params[:q].first == " "
  end
end
