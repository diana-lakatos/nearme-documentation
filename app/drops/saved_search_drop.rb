class SavedSearchDrop < BaseDrop
  attr_reader :saved_search

  # title
  #   title of this saved search
  # path
  #   the full url path of the query
  # new_results
  #   number of new results in the app for this saved query
  delegate :id, :title, :path, :new_results, to: :saved_search

  def initialize(saved_search)
    @saved_search = saved_search
  end

  # url to the saved searches section in the user's dashboard
  def dashboard_saved_searches_url
    routes.dashboard_saved_searches_path
  end
end
