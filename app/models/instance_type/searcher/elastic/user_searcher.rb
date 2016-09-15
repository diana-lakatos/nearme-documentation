class InstanceType::Searcher::Elastic::UserSearcher

  ALLOWED_QUERY_FIELDS = [:first_name, :last_name, :name, :country_name, :company_name, :tags].freeze

  include InstanceType::Searcher

  attr_reader :filterable_custom_attributes, :search

  def initialize(params, current_user, instance_profile_type)
    @current_user = current_user
    @params = params
    @instance_profile_type = instance_profile_type

    @results = load_results

    set_options_for_filters
  end

  def load_results
    user_ids = fetcher.map(&:id)

    order_ids = user_ids

    results = User.where(id: user_ids).not_admin


    results.includes(:current_address).order_by_array_of_ids(order_ids)
  end

  def fetcher
    @fetcher ||=
      begin
        @search_params = @params.merge({
          sort: (@params[:sort].presence || 'relevance').inquiry,
          limit: @params[:per_page],
          page: @params[:page]
        })

        searcher_params = initialize_search_params.merge(@search_params)

        User.regular_search(searcher_params, @instance_profile_type)
      end
  end

  def searchable_categories
    @instance_profile_type.categories.searchable.roots.includes(children: [:children])
  end

  def search
    @search ||= ::User::Search::Params::Web.new(@params, @instance_profile_type)
  end

  def search_query_values
    { :query => @params[:query] }.merge(filters)
  end

  def filters
    search_filters = {}

    search_filters
  end

  def set_options_for_filters
  end

  def to_event_params
    { search_query: query, result_count: result_count }
  end

  private

  def initialize_search_params
    { instance_id: PlatformContext.current.instance.id, instance_profile_type_id: @instance_profile_type.id }
  end

end