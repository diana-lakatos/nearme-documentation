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

  # Tracks event in google analytics. Should be moved to background.
  def track(category, action)
    if tracking_code.present?
      params = get_params(category, action)
      begin
        # documentation says that the request should be post, but actually must be get. not a mistake - tested!
        RestClient.get(endpoint_url, params: params, timeout: 4, open_timeout: 4)
        Rails.logger.info "Tracked google_analytics event #{params.inspect}"
        return true
      rescue  RestClient::Exception => rex
        Rails.logger.info "error tracking google_analytics event #{params.inspect}: #{rex}"
        return false
      end
    else
      Rails.logger.debug "dummy track google analtyics event #{params.inspect}"
    end
  end

  def get_params(category, action)
    {
      v: version,
      tid: tracking_code,
      cid: @current_user.try(:google_analytics_id) ? @current_user.google_analytics_id : '555',
      t: "event",
      ec: category,
      ea: action
    }
  end

  def endpoint_url
    "http://www.google-analytics.com/collect"
  end

  def tracking_code
    DesksnearMe::Application.config.google_analytics[:tracking_code]
  end

  def version
    # google analytics API version
    1
  end

end
