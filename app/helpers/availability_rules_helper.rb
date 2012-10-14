module AvailabilityRulesHelper
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
      choices << [template.id, "#{template.name} (#{template.description})", { :id => "availability_template_id_#{template.id.to_s.downcase}" }]
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
      [0, 15, 45].each do |minute|
        hour_for_display = hour % 12 == 0 ? 12 : hour % 12
        options << ["#{hour_for_display}:#{'%0.2d' % minute} #{hour < 12 ? 'AM' : 'PM'}", "#{hour}:#{minute}"]
      end
    end
    options
  end
end
