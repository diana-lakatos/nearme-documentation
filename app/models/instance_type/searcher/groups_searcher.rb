class InstanceType::Searcher::GroupsSearcher
  include InstanceType::Searcher

  def initialize(params, current_user)
    @params = params
    @results = fetcher
  end

  def fetcher
    @fetcher = Group.search_by_query([:name, :description, :summary], @params[:query])
  end

  def search_query_values
    {
      query: @params[:query]
    }
  end

  def to_event_params
    {
      search_query: query,
      result_count: result_count
    }
  end

end
