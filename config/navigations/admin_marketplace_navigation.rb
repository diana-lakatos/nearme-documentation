# frozen_string_literal: true
SimpleNavigation::Configuration.run do |navigation|
  navigation.id_generator = proc { |key| "nav-config-marketplace-#{key}" }

  navigation.items do |nav|
    nav.item :general, 'General Settings', admin_path(page: 'marketplace_wizard_general')
    nav.item :users, 'Users', admin_path(page: 'marketplace_wizard_users')
    nav.item :languages, 'Languages', admin_path(page: 'marketplace_wizard_languages')
  end
end
