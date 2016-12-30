# frozen_string_literal: true
namespace :uot do
  desc 'Setup UoT'

  require Rails.root.join('lib', 'tasks', 'uot', 'uot_setup.rb')

  task update: :environment do
    @instance = Instance.find(195)
    @instance.set_context!
    @instance.reservation_types.each {|r| r.settings.merge({edit_unconfirmed: 'true'}); r.save(validate: false) }

    setup = UotSetup.new(@instance)

    setup.load_template('instance_admin/manage/orders/index', false)
    setup.load_template('dashboard/company/transactables/sme_listing')

    uot_locales = YAML.load_file(Rails.root.join('lib', 'tasks', 'uot', 'uot.en.yml'))
    uot_locales_hash = convert_hash_to_dot_notation(uot_locales['en'])

    uot_locales_hash.each_pair do |key, value|
      next unless key.include?('instance_admin')
      setup.create_translation!(key, value)
      print '.'
      $stdout.flush
    end

    setup.create_translation!('flash_messages.dashboard.order_items.approve_failed', 'Your Credit Card could not be charged.')
    puts ''
  end

  task setup: :environment do
    @instance = Instance.find(195)
    @instance.update_attributes(
      split_registration: true,
      enable_reply_button_on_host_reservations: true,
      hidden_ui_controls: {
        'main_menu/cta': 1,
        'dashboard/offers': 1,
        'dashboard/user_bids': 1,
        'dashboard/host_reservations': 1,
        'main_menu/my_bookings': 1
      },
      skip_company: true,
      click_to_call: true,
      wish_lists_enabled: true,
      default_currency: 'USD',
      default_country: 'United States',
      force_accepting_tos: true,
      user_blogs_enabled: true,
      force_fill_in_wizard_form: true,
      # test_twilio_consumer_key: 'ACc6efd025edf0bccc089965cdb7a63ed7',
      # test_twilio_consumer_secret: '0bcda4577848ec9708905296efcf6aa3',
      test_twilio_from_number: '+1 703-898-8300',
      test_twilio_consumer_key: 'AC107ea702c0d8255b0afc2baff62c345c',
      test_twilio_consumer_secret: 'df396dbe315d3e3d233ac76e49a1fabd',
      twilio_consumer_key: 'AC107ea702c0d8255b0afc2baff62c345c',
      twilio_consumer_secret: 'df396dbe315d3e3d233ac76e49a1fabd',
      twilio_from_number: '+1 703-898-8300'
      # TODO: reenable for production
      # linkedin_consumer_key: '78uvu99t7fxfcz',
      # linkedin_consumer_secret: 'NGaQfcPmglHuaLOX'
    )
    @instance.create_documents_upload(
      enabled: true,
      requirement: 'mandatory'
    )
    @instance.save
    @instance.set_context!

    @default_profile_type = InstanceProfileType.find(569)
    @instance_profile_type = InstanceProfileType.find(571)
    @instance_profile_type.update_columns(
      onboarding: true,
      create_company_on_sign_up: true,
      show_categories: true,
      category_search_type: 'AND',
      searchable: true,
      search_only_enabled_profiles: true
    )

    setup = UotSetup.new(@instance)
    setup.create_transactable_types!
    setup.create_custom_attributes!
    setup.create_custom_model!
    setup.create_categories!
    setup.create_or_update_form_components!
    setup.set_theme_options
    setup.create_content_holders
    setup.create_views
    setup.create_translations
    setup.create_workflow_alerts
    setup.expire_cache
  end
end
