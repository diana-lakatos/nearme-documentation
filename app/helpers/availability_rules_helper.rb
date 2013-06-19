module AvailabilityRulesHelper

  def availability_summary_for_rules(rules)
    AvailabilityRule::Summary.new(rules)
  end

  def availability_choices(object)
    # Whether or not the "Custom" rules option is checked. There is a case where this is forced off (defer)
    custom_checked = object.availability_template_id.blank?

    # Our set of choice options
    choices = []

    # Are we dealing with an object that can "defer" availability rules to another object?
    if object.respond_to? :defer_availability_rules
      defer_options = { :id => "availability_rules_defer", :'data-clear-rules' => true }
      if object.defer_availability_rules?
        defer_options[:checked] = true

        # In deferring, custom is not checked.
        custom_checked = false
      end

      choices << ['', "Use Location availability", defer_options]
    end

    # Add choices for each of the pre-defined templates
    AvailabilityRule.templates.each do |template|
      choices << [template.id, template.full_name, { :id => "availability_template_id_#{template.id.to_s.downcase}" }]
    end

    # Add choice for the 'Custom' rule creation
    custom_options = { :id => "availability_rules_custom", :'data-custom-rules' => true }
    custom_options[:checked] = custom_checked if custom_checked
    choices << ['custom', "Custom", custom_options]

    # Return our set of choices
    choices
  end

  def availability_time_options
    options = []
    (0..23).each do |hour|
      [0, 15, 30, 45].each do |minute|
        hour_for_display = hour % 12 == 0 ? 12 : hour % 12
        options << ["#{hour_for_display}:#{'%0.2d' % minute} #{hour < 12 ? 'AM' : 'PM'}", "#{hour}:#{'%0.2d' % minute}"]
      end
    end
    options
  end

  def availability_custom?(object)
    object.availability_template_id.blank? && (!object.respond_to?(:defer_availability_rules) || !object.defer_availability_rules?)
  end
  
  # First revision of this method. Will be refined!
  def pretty_availability_sentence(availability)
    days = availability.full_week.select { |d| availability.open_on?(day: d[:day]) }
    hours = days.group_by { |day| rule = day[:rule]; [[rule.open_hour, rule.open_minute], [rule.close_hour, rule.close_minute]] }
    hour_groups = hours.collect { |time, days| { times: time, days: days.map { |h| h.fetch(:day) }} }
    
    sentence = []
    
    hour_groups.each do |group|
      day_ranges, current_range, n = [], [], nil
      
      group[:days].each do |d|
        if n.nil? or n + 1 == d
          current_range.push(d)
        else
          day_ranges.push(current_range)
          current_range = [d]
        end
        n = d
      end
      day_ranges.push(current_range)
      
      day_part = day_ranges.map do |group|
        str = Date::ABBR_DAYNAMES[group.first]
        str += "-#{Date::ABBR_DAYNAMES[group.last]}" if group.count > 1
        str
      end
      
      hour_part = []
      group[:times].each do |time|
        hour, minutes, ordinal = (time[0] > 12 ? time[0] - 12 : time[0]), time[1].to_s.rjust(2, '0'), (time[0] > 12 ? 'pm' : 'am')
        hour_part << "#{hour}:#{minutes}#{ordinal}"
      end
      
      sentence.push("#{day_part.join(',')} #{hour_part.join('-')}")
    end
    
    sentence.to_sentence
  end
  
end
