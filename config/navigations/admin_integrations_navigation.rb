# frozen_string_literal: true
SimpleNavigation::Configuration.run do |navigation|
  navigation.id_generator = proc { |key| "nav-config-integration-#{key}" }

  navigation.items do |nav|
    nav.item :api, 'API', '#'
    nav.item :authentication, 'Authentication', '#'
    nav.item :google_analytics, 'Google Analytics', '#'
    nav.item :shippo, 'Shippo', '#'
    nav.item :olark, 'Olark', '#'
    nav.item :twilio, 'Twilio', '#'
  end
end
