class MixpanelApi

  def initialize(options = {})
    @mixpanel = Mixpanel::Tracker.new MIXPANEL_TOKEN, options
  end

  def track(event_name, properties, options = {})
    @mixpanel.track(event_name, properties, options)
  end

  def track_charge(distinct_id, amount, time = nil, options = {})
    @mixpanel.track_charge(distinct_id, amount, time, options)
  end

  def set(distinct_id_or_request_properties, properties, options = {})
    @mixpanel.set(distinct_id_or_request_properties, properties, options)
  end

  def identify(distinct_id)
    @mixpanel.append_identify(distinct_id)
  end

  def alias_user(distinct_id, previous_distinct_id)
    @mixpanel.append(distinct_id, { distinct_id: previous_distinct_id })
  end

  def register(properties)
    @mixpanel.append_register(properties)
  end

end

