class InstanceType::Searcher::Elastic::GeolocationSearcher::Listing
  include InstanceType::Searcher::Elastic::GeolocationSearcher

  def initialize(transactable_type, params)
    @transactable_type = transactable_type
    set_options_for_filters
    @params = params
    scoped_transactables = []

    fetcher.to_a.map do |f|
      scoped_transactables << ::Transactable.where(id: f['_id'].to_i).first
    end
    scoped_transactables.uniq!
    @search_results_count = scoped_transactables.count
    @results = scoped_transactables
  end

  def filters
    search_filters = {}
    search_filters[:location_type_filter] = @params[:location_types_ids].map { |lt| LocationType.find(lt).name } if @params[:location_types_ids]
    search_filters[:industry_filter] = @params[:industries_ids].map { |i| Industry.find(i).name } if @params[:industries_ids]
    search_filters[:custom_attributes] = @params[:lg_custom_attributes] unless @params[:lg_custom_attributes].blank?
    search_filters
  end

  private

  def initialize_search_params
    { instance_id: PlatformContext.current.instance.id, transactable_type_id: @transactable_type.id }
  end

end