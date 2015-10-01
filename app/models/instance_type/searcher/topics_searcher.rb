class InstanceType::Searcher::TopicsSearcher
  #TODO remove InstanceType::Searcher if not needed
  include InstanceType::Searcher

  attr_reader :search

  def initialize(params, current_user)
    @params = params
    @results = fetcher
  end

  def fetcher
    @fetcher ||= Topic.search_by_query([:name, :description], @params[:query])
  end

  def search_query_values
    {
      query: @params[:query]
    }
  end

  #TODO remove search if not needed
  def search
    @search ||= Spree::Product::Search::Params::Web.new(@params)
  end

  def to_event_params
    { search_query: query, result_count: result_count }
  end
end
