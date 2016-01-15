module AvailabilityRulesHelper

  def availability_summary_for_rules(rules)
    AvailabilityRule::Summary.new(rules)
  end

  def availability_choices(object, id_prefix = '')
    # Our set of choice options
    choices = {}
    # Add choices for each of the pre-defined templates
    parent_objects = [object.instance, object.try(:service_type), object].compact
    AvailabilityTemplate.for_parents(parent_objects).order("transactable_type_id ASC").decorate.each do |template|
      options = {
        id: "#{id_prefix}availability_template_id_#{template.id}",
        description: template.translated_description
      }
      options[:'data-custom-rules'] = true if template.custom?
      choices[template.parent_type] ||= []
      choices[template.parent_type] << [template.id, template.translated_name, options]
    end

    unless object.try(:hide_defered_availability_rules?)
      defer_options = { :id => "availability_rules_defer" }
      defer_options[:description] = object.location.try(:availability) ? pretty_availability_sentence(object.location.availability).to_s : t('simple_form.hints.availability_template.description.location_hours')
      choices['use_location'] = [['', t('simple_form.labels.availability_template.use_parent_availability'), defer_options]]
    end

    #Add choice for the 'Custom' rule creation
    unless choices['Transactable'] || choices['Location']
      custom_options = {
        :id => "#{id_prefix}availability_rules_custom",
        :'data-custom-rules' => true,
        description: t('simple_form.hints.availability_template.description.custom')
      }
      custom_options[:checked] = object.custom_availability_template?
      choices['Transactable'] = [['custom', t('simple_form.labels.availability_template.custom'), custom_options]]
    end

    # Return our set of choices in proper order
    choices = [choices['Instance'], choices['ServiceType'], choices['use_location'], choices['User'], choices['Transactable'], choices['Location']].flatten(1).compact
    choices.first.last[:checked] = true unless choices.find{|ch| ch.last[:checked]}
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
    object.custom_availability_template?
  end

  # First revision of this method. Will be refined!
  def pretty_availability_sentence(availability)
    rules = availability.rules
    hour_groups =  rules.inject([]) do |hour_groups_arr, rule|
      hour_groups_arr << {
        times:  [[rule.open_hour, rule.open_minute], [rule.close_hour, rule.close_minute]],
        days: rule.days
      }
    end

    sentence = []

    hour_groups.each do |group|
      day_ranges, current_range, n = [], [], nil

      group[:days].each do |d|
        if n.nil? || (n + 1) % 7 == d
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
        str += "&ndash;#{Date::ABBR_DAYNAMES[group.last]}" if group.count > 1
        str
      end

      hour_part = []
      group[:times].each do |time|
        hour, minutes, ordinal = (time[0] > 12 ? time[0] - 12 : time[0]), time[1].to_s.rjust(2, '0'), (time[0] > 12 ? 'pm' : 'am')
        hour_part << "#{hour}:#{minutes}#{ordinal}"
      end

      sentence.push("#{day_part.join(',')} #{hour_part.join("&ndash;")}")
    end

    sentence.to_sentence.html_safe
  end

end
