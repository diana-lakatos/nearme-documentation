# frozen_string_literal: true
class SavedSearchDrop < BaseDrop
  # @return [SavedSearchDrop]
  attr_reader :saved_search

  # @!method id
  #   @return [Integer] numeric identifier for the object
  # @!method title
  #   @return [String] title of this saved search
  # @!method path
  #   @return [String] the full path of the query
  # @!method new_results
  #   @return [Integer] Number of new results in the app for this saved query
  delegate :id, :title, :path, :new_results, to: :saved_search

  def initialize(saved_search)
    @saved_search = saved_search
  end

  # @return [String] url to the saved searches section in the user's dashboard
  # @todo -- deprecate -- url filter
  def dashboard_saved_searches_url
    routes.dashboard_saved_searches_path
  end
end
