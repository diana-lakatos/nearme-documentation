class Mixpanel::Presenter::Funnel

  RETRY_HTTP_CALL = 10

  def initialize(name)
    @name = name
    load_data 
    if data_loaded?
      @data = @response["data"]
      @data_first_period = @data[@data.keys.first]
    end
  end

  def load_data
    retries = RETRY_HTTP_CALL
    begin 
      @response =  Mixpanel::DataReceiver.new.get_funnel_data(@name)
    rescue Timeout::Error
      if retries > 0
        retries -= 1
        retry
      else
        Rails.logger.error "Mixpanel::Presenter::Funnel Timeout when loading data for #{@name}"
        @response = {}
      end
    end
  end

  def data_loaded?
    @data_loaded ||= @response && @response["data"] && !@response["data"].empty?
  end

  def name
    @name
  end

  def dom_id
    @dom_id ||= name.tr(" ", "_").downcase
  end

  def dates
    if data_loaded?
      "#{@data.keys.first} - #{@data.keys.last.to_date - 1.day}"
    else
      ""
    end
  end

  def chart_values
    @chart_values ||= begin 
      i = 0
      @data_first_period.each.inject({}) do |result, (instance_id, instance_data)|
        if valid_instance_id?(instance_id)
          result[i] = []
          instance_data.each do |data|
            result[i] << data["count"]
          end
          i += 1
        end
        result
      end
    end.to_json.html_safe
  end

  def chart_labels
    @chart_labels ||= @data_first_period[@data_first_period.keys.first].map { |data| data['goal'] }.to_json.html_safe
  end

  def chart_legend
    @chart_legend ||= @data_first_period.each_key.inject([]) do |arr, instance_id|
      if valid_instance_id?(instance_id)
        name = Instance.where(:id => instance_id).first.try(:name)
        arr << name ? name : "Unknown #{instance_id}"
      end
      arr
    end.to_json.html_safe
  end

  private 

  def valid_instance_id?(instance_id)
    instance_id != '$overall'
  end
end
