# Contains shared behaviour for all trackable classes. Adds a heart of those object
#
# Each class that belongs to this module must implement `customized_params()` method
# see https://developers.google.com/analytics/devguides/collection/protocol/v1/
module AnalyticWrapper::GoogleAnalyticsApi::Trackable

  attr_accessor :user_google_analytics_id

  ENDPOINT = "http://www.google-analytics.com/collect" 

  def track
    if tracking_code.present?
      GoogleAnalyticsApiJob.perform(self)
      Rails.logger.info "google analtyics #{self.class.name}: #{params.inspect}"
    else
      Rails.logger.info "dummy google analtyics #{self.class.name}: #{params.inspect}"
    end
  end

  def params
    { 
      v: version,
      tid: tracking_code,
      cid: user_google_analytics_id
    }.merge(customized_params)
  end

  private

  def tracking_code
    DesksnearMe::Application.config.google_analytics[:tracking_code]
  end

  def version
    # google analytics API version
    1
  end

  def customized_params
    raise "#{self.class.name} must implement params() method"
  end

end
