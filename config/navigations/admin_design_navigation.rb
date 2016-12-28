# frozen_string_literal: true
SimpleNavigation::Configuration.run do |navigation|
  navigation.id_generator = proc { |key| "nav-config-design-#{key}" }

  navigation.items do |nav|
    nav.item :themes, 'Themes', admin_design_themes_path, highlights_on: /admin\/design\/(themes|templates)(\/.+)*/
    nav.item :pages, 'Pages', admin_design_pages_path, highlights_on: /admin\/design\/pages(\/.+)*/
    nav.item :'content-holders', 'Content Holders', admin_design_content_holders_path
    nav.item :files, 'Media library', admin_path(page: 'advanced_wizard_content_holders')
  end
end
