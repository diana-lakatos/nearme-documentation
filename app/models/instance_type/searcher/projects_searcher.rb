# frozen_string_literal: true
class InstanceType::Searcher::ProjectsSearcher
  include InstanceType::Searcher

  attr_reader :search

  def initialize(params, _current_user)
    @params = params
    @results = fetcher
  end

  def fetcher
    @fetcher = Transactable.active.search_by_query([:name, :description, :properties], @params[:query])
    @fetcher = @fetcher.by_topic(selected_topic_ids).custom_order(@params[:sort])
    @fetcher = @fetcher.seek_collaborators if @params[:seek_collaborators] == '1'
    @fetcher = @fetcher.joins(:categories).where(categories: { id: selected_category_ids }).distinct if selected_category_ids.present?
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

  def search_query_values
    {
      query: @params[:query]
    }
  end

  def result_view
    'community'
  end
end
