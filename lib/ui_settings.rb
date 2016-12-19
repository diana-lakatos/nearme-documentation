# frozen_string_literal: true
class UiSettings
  SETTINGS = {
    'help-is-visible': :boolean,
    'help-is-detached': :boolean,
    'help-position': :json
  }.freeze

  def self.parse(key, value)
    raise "Invalid UiSettings key: #{key}" unless SETTINGS.key?(key.to_sym)

    case SETTINGS[key.to_sym]
    when :boolean
      value == 'true'
    when :json
      JSON.parse(value)
    when :integer
      value.to_i
    when :float
      value.to_f
    else
      value
    end
  end
end
