class InstanceType::Searcher::TopicsSearcher
  include InstanceType::Searcher

  attr_reader :search

  def initialize(params, _current_user)
    @params = params
    @results = fetcher
  end

  def fetcher
    @fetcher ||= Topic
                   .search_by_query([:name, :description], @params[:query])
                   .paginate(page: @params[:page], per_page: @params[:per_page])
  end

  def search_query_values
    {
      query: @params[:query]
    }
  end

  def to_event_params
    { search_query: @params[:query], result_count: result_count }
  end
end
