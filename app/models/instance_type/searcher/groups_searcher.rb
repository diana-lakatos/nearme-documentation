class InstanceType::Searcher::GroupsSearcher
  include InstanceType::Searcher

  attr_reader :search

  def initialize(params, current_user)
    @params = params
    @current_user = current_user
    @results = fetcher
  end

  def fetcher
    @fetcher = Group.not_secret.active.search_by_query([:name, :description, :summary], @params[:query])
    @fetcher = @fetcher.where(transactable_type_id: @params[:group_type_id]) if @params[:group_type_id].present?
    @fetcher = @fetcher.custom_order(@params[:sort].try(:to_s).presence || 'members', sort_params)
    @fetcher
  end

  def search_query_values
    {
      query: @params[:query]
    }
  end

  def to_event_params
    {
      search_query: @params[:query],
      result_count: result_count
    }
  end

  private

  def sort_params
    {
      lat: @current_user.try(:current_address).try(:latitude),
      lng: @current_user.try(:current_address).try(:longitude)
    }
  end
end
