class InstanceType::Searcher::PeopleSearcher
  #TODO remove InstanceType::Searcher if not needed
  include InstanceType::Searcher

  attr_reader :search

  def initialize(params, current_user)
    @current_user = current_user
    @params = params
    @results = fetcher
  end

  def fetcher
    @fetcher = User.for_instance(PlatformContext.current.instance).search_by_query([:first_name, :last_name, :name], @params[:query])
    @fetcher = @fetcher.by_topic(selected_values(:topic_ids)).custom_order(@params[:sort], @current_user)
    @fetcher = @fetcher.filtered_by_role(selected_values(:role))
    @fetcher.includes(:current_address)
  end

  def topics_for_filter
    fetcher.map(&:topics).flatten.uniq
  end

  def selected_values(name)
    @params[name].select(&:present?) if @params[name]
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
