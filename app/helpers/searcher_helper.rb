module SearcherHelper

  def result_view
    @result_view = params[:v].presence || (@transactable_type.buyable? ? PlatformContext.current.instance.default_products_search_view : PlatformContext.current.instance.default_search_view)
    @result_view = @result_view.in?(Instance::SEARCH_SERVICE_VIEWS + Instance::SEARCH_PRODUCTS_VIEWS) ? @result_view : 'mixed'
    (@result_view.in?(Instance::SEARCH_PRODUCTS_VIEWS) && !@transactable_type.buyable?) ? 'mixed' : @result_view
  end

  def find_transactable_type

    if params[:buyable] == "true"
      @transactable_type = params[:transactable_type_id].present? ? Spree::ProductType.find(params[:transactable_type_id]) : Spree::ProductType.first
    else
      @transactable_type = params[:transactable_type_id].present? ? TransactableType.find(params[:transactable_type_id]) : TransactableType.first
    end
    params[:transactable_type_id] ||= @transactable_type.id
    @transactable_type
  end

  def instantiate_searcher(transactable_type, params)
    if transactable_type.buyable?
      InstanceType::Searcher::ProductsSearcher.new(transactable_type, params)
    elsif result_view == 'mixed'
      InstanceType::Searcher::GeolocationSearcher::Location.new(transactable_type, params)
    else
      InstanceType::Searcher::GeolocationSearcher::Listing.new(transactable_type, params)
    end
  end

end
