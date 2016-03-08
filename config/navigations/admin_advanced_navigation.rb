# frozen_string_literal: true
SimpleNavigation::Configuration.run do |navigation|
  navigation.id_generator = proc { |key| "nav-config-advanced-#{key}" }

  navigation.items do |nav|
    nav.item :domains, 'Domains', admin_advanced_domains_path
    nav.item :'user-profiles', 'User Profiles', admin_path(page: 'advanced_wizard_user_profiles')
    nav.item :'user-roles', 'User Roles', admin_path(page: 'advanced_wizard_user_roles')
    nav.item :'home-search', 'Home Search', admin_path(page: 'advanced_wizard_home_search')
    nav.item :'wish-lists', 'Wish Lists', admin_path(page: 'advanced_wizard_wishlists')
    nav.item :reviews, 'Reviews', admin_path(page: 'advanced_wizard_reviews')
    nav.item :emails, 'Transactional Emails', admin_path(page: 'advanced_wizard_emails')
    nav.item :sms, 'Text Messages / SMS', admin_path(page: 'advanced_wizard_sms')
    nav.item :'text-filters', 'Text Filters', admin_path(page: 'advanced_wizard_text_filters')
    nav.item :'support-email', 'Support Email', admin_path(page: 'advanced_wizard_support_email')
    nav.item :'custom-attributes', 'Custom Attributes', admin_path(page: 'advanced_wizard_custom_attributes')
    nav.item :validations, 'Validations', admin_path(page: 'advanced_wizard_validations')
    nav.item :'bulk-upload', 'Bulk data upload', admin_path(page: 'advanced_wizard_bulk')
  end
end
