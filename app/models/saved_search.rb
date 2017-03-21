# frozen_string_literal: true
class SavedSearch < ActiveRecord::Base
  ALERTS_FREQUENCIES = %w(daily weekly).freeze

  auto_set_platform_context
  scoped_to_platform_context

  include SearcherHelper

  belongs_to :user, counter_cache: true

  has_many :alert_logs, class_name: 'SavedSearchAlertLog'

  scope :desc, -> { order('id DESC') }

  validates :title, presence: true, uniqueness: { scope: :user_id }
  validates :user_id, :query, presence: true

  before_create :set_last_viewed_at, :change_sort

  # @return [String] the full path of the query
  def path
    Rails.application.routes.url_helpers.search_path + query
  end

  def params
    @params ||= Rack::Utils.parse_query(query.sub('?', '')).with_indifferent_access
  end

  def results_count
    find_transactable_type
    searcher = instantiate_searcher(params)
    # TODO: result_count raises an exception in SQL here for some reason
    searcher.results.size
  end

  def fetch_new_results
    find_transactable_type
    searcher = instantiate_searcher(params)
    searcher.results.select do |object|
      object.created_at > (user.saved_searches_alerts_frequency == 'daily' ? 1.day.ago : 1.week.ago)
    end
  end

  def unseen_results
    alert_logs.where('created_at > ?', last_viewed_at).sum(:results_count)
  end

  def to_liquid
    @saved_search_drop ||= SavedSearchDrop.new(self)
  end

  def query=(val)
    if val.present?
      val = '?' + val unless val.start_with?('?')
    end

    super
  end

  private

  def set_last_viewed_at
    self.last_viewed_at = created_at
  end

  def change_sort
    self.query = query.gsub(/(&)?sort=([a-z\.\_\,]+)?/, '') + '&sort=created_at_desc'
  end
end
