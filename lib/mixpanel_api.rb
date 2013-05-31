class MixpanelApi

  MIXPANEL_TOKEN = if Rails.env.production?
    '7ffff7057407af5fe5f71701a1ab26b2'
  else
    '897e1963583f7dde9ecac901683a9bfa'
  end

  def initialize(options = {})
    @mixpanel = Mixpanel::Tracker.new MIXPANEL_TOKEN, options
  end

  def track(event_name, properties, options = {})
    @mixpanel.track(event_name, properties, options)
  end

  def set(distinct_id_or_request_properties, properties, options = {})
    @mixpanel.set(distinct_id_or_request_properties, properties, options)
  end

  def track_charge(distinct_id, amount, time = nil, options = {})
    @mixpanel.track_charge(distinct_id, amount, time, options)
  end

  def register(properties)
    @mixpanel.register(properties)
  end

end

