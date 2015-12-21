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

  def apply_user(user, options = {})
    @current_user = user
  end

  # Tracks event in google analytics
  def track(*args)
    params = default_params.merge(AnalyticWrapper::GoogleAnalyticsSerializer::Event.new(*args).serialize)
    if tracking_code.present?
      GoogleAnalyticsApiJob.perform(endpoint, params)
      Rails.logger.info "google analtyics track: #{params.inspect}"
    else
      Rails.logger.info "dummy google analtyics track: #{params.inspect}"
    end
  end

  def track_charge(*args)
    item_params = default_params.merge(AnalyticWrapper::GoogleAnalyticsSerializer::Item.new(*args).serialize)
    transaction_params = default_params.merge(AnalyticWrapper::GoogleAnalyticsSerializer::Transaction.new(*args).serialize)
    if tracking_code.present?
      GoogleAnalyticsApiJob.perform(endpoint, transaction_params)
      GoogleAnalyticsApiJob.perform(endpoint, item_params)
      Rails.logger.info "google analtyics track_charge transaction: #{transaction_params.inspect}"
      Rails.logger.info "google analtyics track_charge item: #{item_params.inspect}"
    else
      Rails.logger.info "dummy google analtyics track_charge transaction: #{transaction_params.inspect}"
      Rails.logger.info "dummy google analtyics track_charge item: #{item_params.inspect}"
    end
  end

  private

  def endpoint
    "http://www.google-analytics.com/collect"
  end

  def tracking_code
    PlatformContext.current.domain.try(:google_analytics_tracking_code).presence || DesksnearMe::Application.config.google_analytics[:tracking_code]
  end

  def version
    # google analytics API version
    1
  end

  def default_params
    {
      v: version,
      tid: tracking_code,
      cid: (@current_user.try(:google_analytics_id) ? @current_user.google_analytics_id : '555'),
      an: PlatformContext.current.instance.name
    }
  end

end
