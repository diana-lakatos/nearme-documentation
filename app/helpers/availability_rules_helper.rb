module AvailabilityRulesHelper
  def availability_template_options
    AvailabilityRule.templates.map { |template|
      [template.name, template.id]
    } + [['Custom', ""]]
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
