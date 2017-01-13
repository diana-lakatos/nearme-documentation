class InstanceType::SearcherFactory
  attr_accessor :factory_type, :transactable_type, :params

  def initialize(transactable_type, params, result_view, current_user)
    @transactable_type = transactable_type
    @result_view = result_view
    @factory_type = @transactable_type.search_engine
    @params = params
    @current_user = current_user
  end

  def get_searcher
    if @params[:search_type].in?(%w(topics projects people groups))
      community_searcher
    elsif @transactable_type.is_a? InstanceProfileType
      user_searcher
    elsif @result_view == 'mixed'
      location_searcher
    else
      listing_searcher
    end
  end

  def search_module
    Instance::SEARCH_MODULES[@factory_type] ? "::#{Instance::SEARCH_MODULES[@factory_type]}" : ''
  end

  def location_searcher
    "InstanceType::Searcher#{search_module}::GeolocationSearcher::Location".constantize.new(@transactable_type, @params)
  end

  def listing_searcher
    searcher = "InstanceType::Searcher#{search_module}::GeolocationSearcher::Listing".constantize.new(@transactable_type, @params)
    searcher.invoke
    searcher
  end

  def community_searcher
    if @params[:search_type] == 'people'
      @transactable_type = InstanceProfileType.default.first unless @transactable_type.is_a?(InstanceProfileType)
      @factory_type = @transactable_type.search_engine
      user_searcher
    else
      "InstanceType::Searcher::#{@params[:search_type].titleize}Searcher".constantize.new(@params, @current_user)
    end
  end

  def user_searcher
    if elasticsearch?
      InstanceType::Searcher::Elastic::UserSearcher.new(@params, @current_user, @transactable_type)
    else
      InstanceType::Searcher::UserSearcher.new(@params, @current_user, @transactable_type)
    end
  end

  private

  Instance::SEARCH_ENGINES.each do |se|
    define_method("#{se}?") do
      @factory_type == se
    end
  end
end
