# frozen_string_literal: true
class InstanceType::Searcher::ProjectsSearcher
  include InstanceType::Searcher

  attr_reader :search

  def initialize(params, current_user)
    @params = params
    @current_user = current_user
    @results = fetcher
  end

  def fetcher
    @fetcher = Transactable.active.search_by_query([:name, :description, :properties], @params[:query])
    @fetcher = @fetcher.where("not transactables.properties ? 'visibility' OR transactables.properties -> 'visibility' = 'public'")
    @fetcher = @fetcher.seek_collaborators if @params[:seek_collaborators] == '1'
    @fetcher = @fetcher.joins(:categories).where(categories: { id: selected_category_ids }).distinct if selected_category_ids.present?
    @fetcher = @fetcher.joins(creator: :default_profile).merge(UserProfile.filtered_by_custom_attribute('role', selected_roles)) if selected_roles.present?

    order_by_distance_to_current_user if @params[:sort] == 'Near Me'

    @fetcher = @fetcher.by_topic(selected_topic_ids).custom_order(@params[:sort])
    @fetcher = @fetcher.group('transactable_topics.id') if @params[:sort] =~ /collaborators/i && selected_topic_ids.present?

    @fetcher = @fetcher.paginate(page: @params[:page], per_page: @params[:per_page])
    @fetcher
  end

  def topics_for_filter
    fetcher.map(&:topics).flatten.uniq
  end

  def selected_topic_ids
    @params[:topic_ids]&.select(&:present?)
  end

  def selected_category_ids
    @params[:category_ids]&.select(&:present?)
  end

  def selected_roles
    @params[:roles]&.select(&:present?)
  end

  def search_query_values
    {
      query: @params[:query]
    }
  end

  def result_view
    'community'
  end

  private

  def order_by_distance_to_current_user
    return unless current_address

    @fetcher = @fetcher.joins(creator: :current_address)
                 .order(Address.order_by_distance_sql(current_address.latitude, current_address.longitude))
  end

  def current_address
    @current_address ||= @current_user&.current_address
  end
end
