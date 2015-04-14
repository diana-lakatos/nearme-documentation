class SavedSearch < ActiveRecord::Base

  ALERTS_FREQUENCIES = %w(daily weekly)

  auto_set_platform_context
  scoped_to_platform_context

  include SearcherHelper

  belongs_to :user, counter_cache: true

  scope :desc, -> { order('id DESC') }

  validates :title, presence: true, uniqueness: {scope: :user_id}
  validates :user_id, :query, presence: true

  def path
    Rails.application.routes.url_helpers.search_path + query
  end

  def params
    @params ||= Rack::Utils.parse_query(query.sub('?', '')).with_indifferent_access
  end

  def results_count
    find_transactable_type
    searcher = instantiate_searcher(@transactable_type, params)
    # TODO: result_count raises an exception in SQL here for some reason
    searcher.results.size
  end

  def fetch_new_results
    find_transactable_type
    searcher = instantiate_searcher(@transactable_type, params)
    searcher.results.select do |object|
      object.created_at > (user.saved_searches_alerts_frequency == 'daily' ? 1.day.ago : 1.week.ago)
    end
  end

  def to_liquid
    SavedSearchDrop.new(self)
  end

end
