class TagsController < ApplicationController

  before_action :coerce_query
  before_action :find_user
  before_action :empty_result

  def index
    tags = Tag.autocomplete(params[:q])
    render json: tags, root: false
  end

  private

  # If we have a leading whitespace, we'd like to search for all terms.
  # This is a way to accomplish combo-box-like feature.
  def coerce_query
    params[:q].to_s.lstrip!
  end

  def find_user
    @user = User.find(params[:user_id])
  end

  def empty_result
    render(json: [], root: false) if params[:q].nil?
  end

end
