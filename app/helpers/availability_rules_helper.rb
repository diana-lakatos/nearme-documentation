module AvailabilityRulesHelper
  def availability_summary_for_rules(rules)
    AvailabilityRule::Summary.new(rules)
  end

  def availability_choices(object, id_prefix = '')
    # Our set of choice options
    choices = {}
    # Add choices for each of the pre-defined templates
    parent_objects = [object.instance, object.try(:transactable_type), object].compact
    AvailabilityTemplate.for_parents(parent_objects).order('transactable_type_id ASC').decorate.each do |template|
      options = {
        id: "#{id_prefix}availability_template_id_#{template.id}",
        value: template.id,
        checked: object.availability_template_id == template.id,
        description: template.translated_description
      }
      options[:'data-custom-rules'] = true if template.custom?
      choices[template.parent_type] ||= []
      choices[template.parent_type] << [template.id, template.translated_name, options]
    end

    unless object.try(:hide_location_availability?)
      defer_options = {
        value: '',
        id: 'availability_rules_defer'
        }
      defer_options[:description] = object.transactable.location.try(:availability) ? pretty_availability_sentence(object.transactable.location.availability).to_s : I18n.t('simple_form.hints.availability_template.description.location_hours')
      choices['use_location'] = [['', I18n.t('simple_form.labels.availability_template.use_parent_availability'), defer_options]]
    end

    # Add choice for the 'Custom' rule creation
    unless choices['Transactable::TimeBasedBooking'] || choices['Location']
      custom_options = {
        id: "#{id_prefix}availability_rules_custom",
        value: 'custom',
        'data-custom-rules': true,
        description: I18n.t('simple_form.hints.availability_template.description.custom')
      }
      custom_options[:checked] = availability_custom?(object)
      choices['Transactable::TimeBasedBooking'] = [['custom', I18n.t('simple_form.labels.availability_template.custom'), custom_options]]
    end
    # Return our set of choices in proper order
    choices = [choices['Instance'], choices['TransactableType'], choices['use_location'], choices['User'], choices['Transactable::TimeBasedBooking'], choices['Location']].flatten(1).compact
    choices.first.last[:checked] = true unless choices.find { |ch| ch.last[:checked] }
    choices
  end

  def availability_time_options
    options = []
    (0..23).each do |hour|
      [0, 15, 30, 45].each do |minute|
        hour_for_display = (hour % 12).zero? ? 12 : hour % 12
        options << ["#{hour_for_display}:#{'%0.2d' % minute} #{hour < 12 ? 'AM' : 'PM'}", "#{hour}:#{'%0.2d' % minute}", { 'data-time': "#{hour}#{'%0.2d' % minute}" }]
      end
    end
    options
  end

  def availability_custom?(object)
    object.custom_availability_template?
  end

  # First revision of this method. Will be refined!
  def pretty_availability_sentence(availability)
    return '' unless availability.present?
    rules = availability.rules
    hour_groups =  rules.inject([]) do |hour_groups_arr, rule|
      hour_groups_arr << {
        times:  [[rule.open_hour, rule.open_minute], [rule.close_hour, rule.close_minute]],
        days: rule.days
      }
    end

    sentence = []

    hour_groups.each do |group|
      day_ranges = []
      current_range = []
      n = nil

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

      day_part = day_ranges.map do |range|
        str = Date::ABBR_DAYNAMES[range.first]
        str += "&ndash;#{Date::ABBR_DAYNAMES[range.last]}" if range.count > 1
        str
      end

      hour_part = []
      group[:times].each do |time|
        hour = (time[0] > 12 ? time[0] - 12 : time[0])
        minutes = time[1].to_s.rjust(2, '0')
        ordinal = (time[0] > 12 ? 'pm' : 'am')

        hour_part << I18n.l(DateTime.parse("#{hour}:#{minutes}#{ordinal}"), format: :short)
      end

      sentence.push("#{day_part.join(',')} #{hour_part.join('&ndash;')}")
    end

    sentence.to_sentence.html_safe
  end

  def pretty_time_from_hour_and_minute(hour_part, minute_part)
    hour = (hour_part > 12 ? hour_part - 12 : hour_part)
    minutes = minute_part.to_s.rjust(2, '0')
    ordinal = (hour_part > 12 ? 'pm' : 'am')
    I18n.l(DateTime.parse("#{hour}:#{minutes}#{ordinal}"), format: :short)
  end

  def pretty_availability_rule_time(rule)
    "#{pretty_time_from_hour_and_minute(rule.open_hour, rule.open_minute)}&ndash;#{pretty_time_from_hour_and_minute(rule.close_hour, rule.close_minute)}"
  end

  def pretty_availability_rule_time_with_time_zone(rule, time_zone)
    "#{pretty_availability_rule_time(rule)} #{I18n.l(Time.now.in_time_zone(time_zone), format: '(%Z)')}"
  end
end
