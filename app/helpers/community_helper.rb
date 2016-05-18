module CommunityHelper

  def prepare_search_url(extra_params = {})
    extra_params[:query] = params[:query]
    search_url(extra_params)
  end

end
