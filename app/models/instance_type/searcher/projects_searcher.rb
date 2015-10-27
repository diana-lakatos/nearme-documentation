class InstanceType::Searcher::ProjectsSearcher
  #TODO remove InstanceType::Searcher if not needed
  include InstanceType::Searcher

  attr_reader :search

  def initialize(params, current_user)
    @params = params
    @results = fetcher
  end

  def fetcher
    @fetcher  = Project.enabled.search_by_query([:name, :description], @params[:query])
    @fetcher = @fetcher.by_topic(selected_topic_ids).custom_order(@params[:sort])
    @fetcher = @fetcher.seek_collaborators if @params[:seek_collaborators] == "1"
    @fetcher.includes(:topics, :creator)
  end

  def topics_for_filter
    fetcher.map(&:topics).flatten.uniq
  end

  def selected_topic_ids
    @params[:topic_ids].select(&:present?) if @params[:topic_ids]
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
