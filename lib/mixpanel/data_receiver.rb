class Mixpanel::DataReceiver

  def initialize
    @mixpanel = Mixpanel::Client.new(MIXPANEL_SETTINGS)
  end
  
  def get_funnels
    @funnels ||= @mixpanel.request('funnels/list', {})
  end

  def get_funnel_id(funnel_name)
    funnel = get_funnels.detect { |f| f['name'] == funnel_name }
    if funnel
      funnel['funnel_id']
    else
      nil
    end
  end

  def get_funnel_data(name, options = {})
    options.reverse_merge!(get_default_funnel_params)
    options[:funnel_id] = get_funnel_id(name)
    if options[:funnel_id]
      @mixpanel.request('funnels', options)
    else
      {}
    end
  end

  def get_default_funnel_params
    {
      unit: 'week',
      on: 'properties["current_instance_id"]'
    }
  end

end
