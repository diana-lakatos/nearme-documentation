class Analytics

  MIXPANEL_TOKEN = if Rails.env.production?
    '7ffff7057407af5fe5f71701a1ab26b2'
  else
    '1116470b98f6daff9fb0e638cc24b87f'
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

end

