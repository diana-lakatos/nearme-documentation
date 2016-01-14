module SearcherHelper

  def result_view
    return @result_view = 'community' if PlatformContext.current.instance.is_community?
    @result_view = params[:v].presence
    @result_view = @result_view.in?(@transactable_type.available_search_views) ? @result_view : @transactable_type.default_search_view
  end

  def find_transactable_type
    if params[:transactable_type_class].in? Instance::SEARCHABLE_CLASSES
      @transactable_type = params[:transactable_type_class].constantize.find(params[:transactable_type_id]) if params[:transactable_type_id].present?
    elsif params[:transactable_type_id].present?
      @transactable_type = TransactableType.find(params[:transactable_type_id])
    end
    @transactable_type ||= TransactableType.searchable.by_position.first
    params[:transactable_type_id] ||= @transactable_type.try(:id)
    lookup_context.try(:transactable_type_id=, params[:transactable_type_id]) if respond_to?(:lookup_context)

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
