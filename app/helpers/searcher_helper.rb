module SearcherHelper
  def result_view
    return @result_view = 'index' if PlatformContext.current.custom_theme.present?
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
    unless @transactable_type
      Instance::SEARCHABLE_CLASSES.each do|_klass|
        @transactable_type ||= _klass.constantize.searchable.by_position.first
      end
    end

    if @transactable_type.blank?
      flash[:error] = t('flash_messages.search.missing_transactable_type')
      return redirect_to root_path
    end

    # TODO: as a lookup context we use TransactableType, but search can by for
    # InstanceProfileType, this is temporary workaround. I think we need to add
    # IPT as a lookup_context for InstanceViews
    params[:transactable_type_id] ||= @transactable_type.id
    if @transactable_type.is_a?(TransactableType)
      lookup_context.try(:transactable_type_id=, @transactable_type.id) if respond_to?(:lookup_context)
    else
      lookup_context.try(:transactable_type_id=, TransactableType.first.id) if respond_to?(:lookup_context)
    end
  end

  def instantiate_searcher(transactable_type, params)
    if result_view == 'mixed'
      InstanceType::Searcher::Elastic::GeolocationSearcher::Location.new(transactable_type, params)
    else
      searcher = InstanceType::Searcher::Elastic::GeolocationSearcher::Listing.new(transactable_type, params)
      searcher.invoke
      searcher
    end
  end

  def search_breadcrumb(searcher)
    text = "#{searcher.result_count} results"
    text += " for \"#{@searcher.query}\"" if searcher.query.present?
    text
  end
end
