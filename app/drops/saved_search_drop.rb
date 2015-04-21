class SavedSearchDrop < BaseDrop

  attr_reader :saved_search

  delegate :id, :title, :path, :new_results, to: :saved_search

  def initialize(saved_search)
    @saved_search = saved_search
  end

  def dashboard_saved_searches_url
    routes.dashboard_saved_searches_path
  end

end
