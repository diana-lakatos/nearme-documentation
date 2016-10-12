class SavedSearchAlertLog < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :saved_search

  validates_presence_of :saved_search_id, :results_count
end
