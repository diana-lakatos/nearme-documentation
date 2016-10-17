class SavedSearchDrop < BaseDrop
  
  # @return [SavedSearch]
  attr_reader :saved_search

  # @!method id
  #   @return [Integer] numeric identifier for the object
  # @!method title
  #   Title of this saved search
  #   @return (see SavedSearch#title)
  # @!method path
  #   @return (see SavedSearch#path)
  # @!method new_results
  #   Number of new results in the app for this saved query
  #   @return (see SavedSearch#new_results)
  delegate :id, :title, :path, :new_results, to: :saved_search

  def initialize(saved_search)
    @saved_search = saved_search
  end

  # @return [String] url to the saved searches section in the user's dashboard
  def dashboard_saved_searches_url
    routes.dashboard_saved_searches_path
  end
end
