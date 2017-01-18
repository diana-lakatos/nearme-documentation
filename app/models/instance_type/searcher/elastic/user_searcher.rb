class InstanceType::Searcher::Elastic::UserSearcher
  ALLOWED_QUERY_FIELDS = [:first_name, :last_name, :name, :country_name, :company_name, :tags].freeze

  include InstanceType::Searcher

  attr_reader :filterable_custom_attributes, :search

  def initialize(params, current_user, instance_profile_type)
    @current_user = current_user
    @params = params
    @instance_profile_type = instance_profile_type
  end

  def fetcher
    @fetcher ||= User.regular_search(search_params, @instance_profile_type)
  end

  def searchable_categories
    @instance_profile_type.categories.searchable.roots.includes(children: [:children])
  end

  def search
    @search ||= ::User::Search::Params::Web.new(@params, @instance_profile_type)
  end

  def search_query_values
    { query: @params[:query] }
  end

  # page-page and page for ES and PG are not the same thing
  # when paging PG results based on ES search we take only first page
  def results
    @results ||= load_results
                   .paginate(page: @params[:page], per_page: @params[:per_page], total_entries: @fetcher.results.total)
                   .offset(0)
  end

  private

  # TODO: 1. coerse pagination params at this stage
  # TODO: 2. standarise category_ids format - array<integer> or string of integers comma sepd
  def search_params
    default_search_params.merge sort: (@params[:sort].presence || 'relevance').inquiry,
                                limit: @params[:per_page],
                                page: @params[:page],
                                category_ids: Array(@params[:category_ids]).reject(&:blank?).join(',')
  end

  def default_search_params
    @params.merge instance_id: PlatformContext.current.instance.id,
                  instance_profile_type_id: @instance_profile_type.id
  end

  # TODO: merge already fetched data from ES with state from DB
  def load_results
    User
      .where(id: user_ids)
      .not_admin
      .includes(:current_address, :blog, :tags, :communication)
      .references(:tags, :communication)
      .order_by_array_of_ids(user_ids)
  end

  def user_ids
    @user_ids = fetcher.map(&:id)
  end
end
