class InstanceType::SearcherFactory

  DEFAULT_SEARCH_MODULE = 'postgres'

  attr_accessor :factory_type, :transactable_type, :params

  def initialize(transactable_type, params, result_view, current_user)
    @transactable_type = transactable_type
    @result_view = result_view
    @factory_type = if Rails.configuration.force_disable_es
      DEFAULT_SEARCH_MODULE
    else
      @transactable_type.search_engine
    end
    @params = params
    @current_user = current_user
  end

  def get_searcher
    if @params[:search_type].in? %w(topics projects people)
      community_searcher
    elsif @transactable_type.buyable?
      product_searcher
    elsif @result_view == 'mixed'
      location_searcher
    else
      listing_searcher
    end
  end

  def search_module
    Instance::SEARCH_MODULES[@factory_type] ? "::#{Instance::SEARCH_MODULES[@factory_type]}" : ''
  end

  def product_searcher
    "InstanceType::Searcher#{search_module}::ProductsSearcher".constantize.new(@transactable_type, @params)
  end

  def location_searcher
    "InstanceType::Searcher#{search_module}::GeolocationSearcher::Location".constantize.new(@transactable_type, @params)
  end

  def listing_searcher
    "InstanceType::Searcher#{search_module}::GeolocationSearcher::Listing".constantize.new(@transactable_type, @params)
  end

  def community_searcher
    "InstanceType::Searcher#{search_module}::#{@params[:search_type].titleize}Searcher".constantize.new(@params, @current_user)
  end

  private

  Instance::SEARCH_ENGINES.each do |se|
    define_method("#{se}?") do
      @factory_type == se
    end
  end

end
