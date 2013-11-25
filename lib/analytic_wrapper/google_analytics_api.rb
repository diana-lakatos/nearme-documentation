# Our internal wrapper for Google Analytics calls.
#
# Provides an internal interface for triggering Google Analytics calls
# with the correct user data, persisted properties, etc.
# see https://developers.google.com/analytics/devguides/collection/protocol/v1/
class AnalyticWrapper::GoogleAnalyticsApi
  # accordijg to https://developers.google.com/analytics/devguides/collection/protocol/v1/devguide#overview
  # anonymous client_id has id 555.
  def initialize(user)
    @current_user = user
  end

  def apply_user(user)
    @current_user = user
  end

  # Tracks event in google analytics
  def track(*args)
    initiazle_trackable_object(AnalyticWrapper::GoogleAnalyticsApi::Event, *args).track
  end

  def track_charge(*args)
    initiazle_trackable_object(AnalyticWrapper::GoogleAnalyticsApi::Transaction, *args).track
    initiazle_trackable_object(AnalyticWrapper::GoogleAnalyticsApi::Item, *args).track
  end

  private

  def initiazle_trackable_object(object_class, *args)
    object = object_class.new(*args)
    object.user_google_analytics_id = (@current_user.try(:google_analytics_id) ? @current_user.google_analytics_id : '555')
    object
  end

end
