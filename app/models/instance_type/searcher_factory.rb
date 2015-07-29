class InstanceType::SearcherFactory

  DEFAULT_SEARCH_MODULE = 'postgres'

  attr_accessor :factory_type, :transactable_type, :params

  def initialize(transactable_type, params)
    @factory_type = if Rails.configuration.force_disable_es
      DEFAULT_SEARCH_MODULE
    else
      PlatformContext.current.instance.search_engine
    end
    @transactable_type = transactable_type
    @params = params
  end

  def search_module
    Instance::SEARCH_MODULES[@factory_type] ? "::#{Instance::SEARCH_MODULES[@factory_type]}" : ''
  end

  def product_searcher
    "InstanceType::Searcher#{search_module}::ProductsSearcher".constantize.new(@transactable_type, params)
  end

  def location_searcher
    "InstanceType::Searcher#{search_module}::GeolocationSearcher::Location".constantize.new(@transactable_type, params)
  end

  def listing_searcher
    "InstanceType::Searcher#{search_module}::GeolocationSearcher::Listing".constantize.new(@transactable_type, params)
  end

  private

  Instance::SEARCH_ENGINES.each do |se|
    define_method("#{se}?") do
      @factory_type == se
    end
  end

end
