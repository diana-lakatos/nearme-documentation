module SearcherHelper

  def result_view
    @result_view = params[:v].presence || (@transactable_type.buyable? ? PlatformContext.current.instance.default_products_search_view : PlatformContext.current.instance.default_search_view)
    @result_view = @result_view.in?(Instance::SEARCH_SERVICE_VIEWS + Instance::SEARCH_PRODUCTS_VIEWS) ? @result_view : 'mixed'
    (@result_view.in?(Instance::SEARCH_PRODUCTS_VIEWS) && !@transactable_type.buyable?) ? 'mixed' : @result_view
    (@result_view.in?(Instance::SEARCH_SERVICE_VIEWS) && @transactable_type.buyable?) ? 'products' : @result_view
  end

  def find_transactable_type
    @transactable_type = TransactableType.find(params[:transactable_type_id]) if params[:transactable_type_id].present?
    @transactable_type ||= (PlatformContext.current.instance.buyable? ?  Spree::ProductType.first : ServiceType.first)
    params[:transactable_type_id] ||= @transactable_type.try(:id)

    if @transactable_type.blank?
      flash[:error] = t('flash_messages.search.missing_transactable_type')
      redirect_to root_path
    end
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

  def search_breadcrumb(searcher)
    text = "#{searcher.result_count} results"
    text += " for \"#{@searcher.query}\"" if searcher.query.present?
    text
  end

end
