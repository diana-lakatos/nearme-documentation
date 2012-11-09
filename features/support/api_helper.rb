module ApiHelper
  def search_for_json(json)
    update_all_indexes
    post "/v1/listings/search", json.to_json
  end
end

World(ApiHelper)
