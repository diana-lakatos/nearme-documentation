namespace :uot do

  desc 'Setup UoT'
  task setup: :environment do

    @instance = Instance.find(195)
    @instance.update_attributes(
      split_registration: true,
      enable_reply_button_on_host_reservations: true,
      hidden_ui_controls: {
        'main_menu/cta': 1,
        'dashboard/offers': 1,
        'dashboard/user_bids': 1,
        'dashboard/host_reservations': 1
      },
      skip_company: true,
      click_to_call: true,
      wish_lists_enabled: true
    )
    @instance.create_documents_upload(
      enabled: true,
      requirement: 'mandatory'
    )
    @instance.save
    @instance.set_context!

    @instance_profile_type = InstanceProfileType.find(571)
    @instance_profile_type.update_columns(
      onboarding: true,
      create_company_on_sign_up: true,
      show_categories: true,
      category_search_type: 'AND',
      searchable: true,
      search_only_enabled_profiles: true
    )

    create_transactable_types!
    create_custom_attributes!
    create_categories!
    create_or_update_form_components!
    set_theme_options
    create_content_holders
    create_views
    create_translations
    create_workflow_alerts
    expire_cache
  end

  def create_transactable_types!
    transactable_type = @instance.transactable_types.where(name: 'Business Services').first
    transactable_type.destroy if transactable_type.present?

    transactable_type = @instance.transactable_types.where(name: 'Project').first_or_initialize
    transactable_type.attributes = {
      name: 'Project',
      slug: 'project',
      show_path_format: '/:transactable_type_id/:id',

      default_search_view: 'list',
      skip_payment_authorization: true,
      hours_for_guest_to_confirm_payment: 24,
      single_transactable: false,
      show_price_slider: true,
      skip_location: true,
      show_categories: true,
      category_search_type: 'OR',
      bookable_noun: 'Project',
      enable_photo_required: false,
      # min_hourly_price_cents: 50_00,
      # max_hourly_price_cents: 150_00,
      lessor: 'Client',
      lessee: 'Expert',
      enable_reviews: true,
      auto_accept_invitation_as_collaborator: true,
      require_transactable_during_onboarding: false
    }

    transactable_type.offer_action ||= transactable_type.build_offer_action(
      enabled: true,
      cancellation_policy_enabled: "1",
      cancellation_policy_hours_for_cancellation: 24,
      cancellation_policy_penalty_hours: 1.5,
      service_fee_guest_percent: 0,
      service_fee_host_percent: 30,
      pricings_attributes: [{
        min_price_cents: 50_00,
        max_price_cents: 150_00,
        unit: 'hour',
        number_of_units: 1,
        order_class_name: 'Offer'
      }]
    )
    transactable_type.save!
    fc = transactable_type.reservation_type.form_components.first
    fc.name = 'Make an Offer'
    fc.form_fields = [{'reservation' => 'payment_documents'}]
    fc.save
  end

  def create_custom_attributes!
    @transactable_type = TransactableType.first
    create_custom_attribute(@transactable_type, {
        name: 'about_company',
        label: 'About Company (short description)',
        attribute_type: 'string',
        html_tag: 'textarea',
        placeholder: 'Description of company',
        required: "1",
        public: true,
        searchable: false
    })
    create_custom_attribute(@transactable_type, {
        name: 'estimation',
        label: 'Approx. Time required to complete',
        attribute_type: 'string',
        html_tag: 'input',
        placeholder: "Enter Amount (months, days, hours)",
        required: "1",
        public: true,
        searchable: false
    })

    create_custom_attribute(@transactable_type, {
        name: 'workplace_type',
        label: 'Workplace Type',
        attribute_type: 'string',
        html_tag: 'select',
        required: "1",
        valid_values: ["Online", "On Site"],
        public: true,
        searchable: true
    })

    create_custom_attribute(@transactable_type, {
        name: 'office_location',
        label: 'Office Location',
        attribute_type: 'string',
        html_tag: 'input',
        required: "0",
        placeholder: "Enter City or Area",
        public: true,
        searchable: false
    })
    create_custom_attribute(@transactable_type, {
        name: 'budget',
        label: 'Approximate value / budget',
        attribute_type: 'float',
        html_tag: 'input',
        placeholder: "Enter Amount",
        required: "1",
        min_length: 1,
        public: true,
        searchable: false
    })
    create_custom_attribute(@transactable_type, {
        name: 'deadline',
        label: 'Deadline',
        attribute_type: 'date',
        html_tag: 'input',
        placeholder: "Enter Amount",
        required: "1",
        public: true,
        searchable: false
    })

    create_custom_attribute(@transactable_type, {
        name: 'type_of_deliverable',
        label: 'Type of Deliverable',
        attribute_type: 'string',
        html_tag: 'textarea',
        placeholder: "",
        required: "0",
        public: true,
        searchable: false
    })

    create_custom_attribute(@transactable_type, {
        name: 'other_requirements',
        label: 'Other Requirements',
        attribute_type: 'string',
        html_tag: 'textarea',
        placeholder: "",
        required: "0",
        public: true,
        searchable: false
    })

    create_custom_attribute(@transactable_type, {
        name: 'project_contact',
        label: 'Project Contact',
        attribute_type: 'string',
        html_tag: 'input',
        placeholder: "Enter Full Name",
        required: "0",
        public: true,
        searchable: false
    })

    create_custom_attribute(@instance_profile_type, {
        name: 'bio',
        label: 'Bio',
        attribute_type: 'string',
        html_tag: 'textarea',
        required: "1",
        validation_only_on_update: true,
        public: true,
        searchable: false
    })

    create_custom_attribute(@instance_profile_type, {
        name: 'workplace_type',
        label: 'Workplace Type',
        attribute_type: 'array',
        html_tag: 'check_box_list',
        required: "1",
        validation_only_on_update: true,
        valid_values: ["Online", "On Site"],
        public: true,
        searchable: true
    })

    create_custom_attribute(@instance_profile_type, {
        name: 'travel',
        label: 'Travel',
        attribute_type: 'string',
        html_tag: 'radio_buttons',
        required: "1",
        validation_only_on_update: true,
        valid_values: ['yes', 'no'],
        public: true,
        searchable: true
    })

    create_custom_attribute(@instance_profile_type, {
        name: 'hourly_rate',
        label: 'Hourly rate',
        attribute_type: 'integer',
        html_tag: 'input',
        required: "1",
        validation_only_on_update: true,
        public: true,
        searchable: false
    })

    create_custom_attribute(@instance_profile_type, {
        name: 'discounts_available',
        label: 'Discounts available',
        attribute_type: 'string',
        html_tag: 'radio_buttons',
        validation_only_on_update: true,
        required: "1",
        valid_values: ['available', 'not_available'],
        public: true,
        searchable: false
    })

    @lister_instance_profile_type = InstanceProfileType.find(570)

    cv = @lister_instance_profile_type.custom_validators.where(field_name: 'mobile_number').first_or_initialize
    cv.required = "1"
    cv.validation_only_on_update = true
    cv.save!

    create_custom_attribute(@lister_instance_profile_type, {
        name: 'google_id',
        label: 'Google ID',
        attribute_type: 'string',
        html_tag: 'input',
        required: "0",
        public: true,
        searchable: false
    })

    create_custom_attribute(@lister_instance_profile_type, {
        name: 'linkedin_id',
        label: 'LinkedIn ID',
        attribute_type: 'string',
        html_tag: 'input',
        required: "0",
        public: true,
        searchable: false
    })

    create_custom_attribute(@lister_instance_profile_type, {
        name: 'twitter_id',
        label: 'Twitter ID',
        attribute_type: 'string',
        html_tag: 'input',
        required: "0",
        public: true,
        searchable: false
    })

    create_custom_attribute(@lister_instance_profile_type, {
        name: 'linkedin_url',
        label: 'LinkedIn URL',
        attribute_type: 'string',
        html_tag: 'input',
        required: "0",
        public: true,
        searchable: false
    })

    create_custom_attribute(@lister_instance_profile_type, {
        name: 'referred_by',
        label: 'Referred By',
        attribute_type: 'string',
        html_tag: 'input',
        required: "0",
        public: true,
        searchable: false
    })

  end

  def create_langauge_categories
    root_category = Category.where(name: 'Languages').first_or_create!
    root_category.transactable_types = TransactableType.all
    root_category.instance_profile_types = [@instance_profile_type]
    root_category.mandatory = true
    root_category.multiple_root_categories = true
    root_category.search_options = 'include'
    root_category.save!

    %w(English Spanish French German Japanese Korean Italian Polish Russian Other).each do |category|
      root_category.children.where(name: category).first_or_create!
    end
  end

  def create_industry_categories
    root_category = Category.where(name: 'Industry').first_or_create!
    root_category.transactable_types = []
    root_category.instance_profile_types = [@instance_profile_type]
    root_category.mandatory = true
    root_category.multiple_root_categories = true
    root_category.search_options = 'include'
    root_category.save!

    ["Aerospace, Defense", "Civilian", "Defense and Intelligence", "Federal Government",
     "Health Payers", "Health Plans", "Healthcare Providers", "High Tech", "Law Enforcement and Homeland Security",
     "Life Sciences, Biotechnology, & Pharmaceutical", "State Government"].each do |category|
      root_category.children.where(name: category).first_or_create!
    end
  end

  def create_area_of_expertise_categories
    root_category = Category.where(name: 'Area Of Expertise').first_or_create!
    root_category.transactable_types = []
    root_category.instance_profile_types = [@instance_profile_type]
    root_category.mandatory = true
    root_category.multiple_root_categories = true
    root_category.search_options = 'include'
    root_category.save!

    ['Management', 'Information Technology'].each do |category|
      root_category.children.where(name: category).first_or_create!
    end
  end

  def create_categories!
    create_langauge_categories
    create_industry_categories
    create_area_of_expertise_categories
  end

  def create_or_update_form_components!
    TransactableType.first.form_components.destroy_all

    component = TransactableType.first.form_components.where(form_type: 'space_wizard').first_or_initialize
    component.name = 'Complete Profile'
    component.form_fields = [
      { "company" => "name" },
      { "user" => "current_address" },
      { "user" => "mobile_phone" },
      { "user" => "google_id" },
      { "user" => "twitter_id" },
      { "user" => "linkedin_id" },
      { "user" => "linkedin_url" },
      { "user" => "avatar" },
      { "user" => "referred_by" }
    ]
    component.save!
    component = TransactableType.first.form_components.where(form_type: 'transactable_attributes').first_or_initialize
    component.name = 'Add a Project'
    component.form_fields = [
      { "transactable" => "name" },
      { "transactable" => "about_company" },
      { "transactable" => "project_contact" },
      { "transactable" => "description" },
      { "transactable" => "type_of_deliverable" },
      { "transactable" => "other_requirements" },
      { "transactable" => "estimation" },
      { "transactable" => "workplace_type" },
      { "transactable" => "office_location" },
      { "transactable" => "Category - Languages" },
      { "transactable" => "budget" },
      { "transactable" => "deadline" }
    ]
    component.save!

    component = @instance_profile_type.form_components.where(form_type: 'buyer_profile_types').first_or_initialize
    component.form_fields = [
      {"buyer" => "enabled"},
      {"buyer" => "bio"},
      {"buyer" => "workplace_type"},
      {"buyer" => "discounts_available"},
      {"buyer" => "hourly_rate"},
      {"buyer" => "travel"},
      {"buyer" => "Category - Languages"},
      {"buyer" => "Category - Industry"},
      {"buyer" => "Category - Area Of Expertise"},
      {"user" => "tags"}
    ]
    component.save!

  end

  def set_theme_options
    theme = @instance.theme

    theme.color_green = '#4fc6e1'
    theme.color_blue = '#05caf9'
    theme.color_red = '#e83d33'
    theme.color_orange = '#ff8d00'
    theme.color_gray = '#394449'
    theme.color_black = '#1e2222'
    theme.color_white = '#fafafa'
    theme.call_to_action = 'Learn more'

    theme.phone_number = '1-555-555-55555'
    theme.contact_email = 'support@uot.com'
    theme.support_email = 'support@uot.com'

    theme.facebook_url = 'https://facebook.com'
    theme.twitter_url = 'https://twitter.com'
    theme.gplus_url = 'https://plus.google.com'
    theme.instagram_url = 'https://www.instagram.com'
    theme.youtube_url = 'https://www.youtube.com'
    theme.blog_url = 'http://blog.com'
    theme.linkedin_url = 'https://www.linkedin.com'

    ['About', 'About', 'How it Works', 'FAQ', 'Terms of Use', 'Privacy Policy'].each do |name|
      slug = name.parameterize
      page = theme.pages.where(slug: slug).first_or_initialize
      page.path = name
      page.content = %Q{
        <div class="wrapper-a"></div>
      }
      page.save
    end

    theme.updated_at = Time.now
    theme.save!
  end

  def create_content_holders
    ch = @instance.theme.content_holders.where(
      name: 'HEAD links and scripts'
    ).first_or_initialize

    ch.update!({
      content: read_template('head.liquid'),
      inject_pages: ['any_page'],
      position: 'head_bottom'
    })

    ch = @instance.theme.content_holders.where(
      name: 'BODY end scripts'
    ).first_or_initialize

    ch.update!({
      content: read_template('body_end.liquid'),
      inject_pages: ['any_page'],
      position: 'body_bottom'
    })
  end

  def expire_cache
    CacheExpiration.send_expire_command 'RebuildInstanceView'
    CacheExpiration.send_expire_command 'Translation', instance_id: 195
    CacheExpiration.send_expire_command 'RebuildCustomAttributes'
    Rails.cache.clear
  end

  def create_views
    create_home_index!
    create_theme_header!
    create_home_search_fulltext!
    create_home_search_custom_attributes!
    create_home_homepage_content!
    create_listing_show!
    create_theme_footer!
    create_search_list!
    create_user_profile!
    create_my_cases!
    create_wish_list_views!
    create_registration_screens!
    create_analytics!
  end

  def create_translations

    transformation_hash = {
      'reservation' => 'offer',
      'Reservation' => 'Offer',
      'booking' => 'offer',
      'Booking' => 'Offer',
      'host' => 'Client',
      'seller' => 'Client',
      'Seller' => 'Client',
      'Host' => 'Client',
      'buyer' => 'Expert',
      'Buyer' => 'Expert',
      'guest' => 'Expert',
      'Guest' => 'Expert',
      'this listing' => 'your Project',
      'that listing' => 'your Project',
      'This listing' => 'Your Project',
      'That listing' => 'Your Project',
      'listing' => 'Project'
    }
    (Dir.glob(Rails.root.join('config', 'locales', '*.en.yml')) + Dir.glob(Rails.root.join('config', 'locales', 'en.yml'))).each do |yml_filename|
      en_locales = YAML.load_file(yml_filename)
      en_locales_hash = convert_hash_to_dot_notation(en_locales['en'])
      en_locales_hash.each_pair do |key, value|
        next if value.blank?
        new_value = value
        transformation_hash.keys.each do |word|
          new_value = new_value.gsub(word, transformation_hash[word])
        end
        if value != new_value
          t = Translation.find_or_initialize_by(locale: 'en', key: key, instance_id: @instance.id)
          t.value = new_value
          t.skip_expire_cache = true
          t.save!
          puts "\t\tTranslation updated: key: #{key}, value: #{value} -> #{t.value}"
        end

      end
    end

    uot_locales = YAML.load_file(Rails.root.join('lib','tasks','uot','uot.en.yml'))
    uot_locales_hash = convert_hash_to_dot_notation(uot_locales['en'])

    uot_locales_hash.each_pair do |key, value|
      create_translation!(key, value)
      puts "\t\tTranslation created: key: #{key}, value: #{value}"
    end
  end

  def create_translation!(key, value)
    @instance.translations.where(
      locale: 'en',
      key: key
    ).first_or_initialize.update!(value: value)
  end

  def convert_hash_to_dot_notation(hash, path = '')
    hash.each_with_object({}) do |(k, v), ret|
      key = path + k

      if v.is_a? Hash
        ret.merge! convert_hash_to_dot_notation(v, key + ".")
      else
        ret[key] = v
      end
    end
  end

  def create_home_index!
    load_template('home/index', false)
  end

  def create_theme_header!
    load_template('layouts/theme_header')
    load_template('layouts/theme_dashboard_header')
  end

  def create_listing_show!
    load_template('listings/show', false)
  end

  def create_theme_footer!
    load_template('layouts/theme_footer')
  end

  def create_search_list!
    load_template('search/list', false)
  end

  def create_user_profile!
    load_template('registrations/show', false)
    load_template('dashboard/company/users/collaborations_for_current_user', false)
    load_template('dashboard/company/transactable_collaborators/transactable_collaborator')
  end

  def create_wish_list_views!
    load_template('dashboard/wish_list_items/wish_list_item')
    load_template('shared/components/wish_list_button')
  end

  def create_my_cases!
    load_template('dashboard/offers/offer')
    load_template('dashboard/company/offers/offer')
    load_template('dashboard/company/transactables/index', false)
    load_template('dashboard/company/transactables/listing')
    load_template('dashboard/company/transactables/sme_actions')
    load_template('dashboard/company/transactables/sme_listing')
    load_template('dashboard/company/transactables/client_listing')
    load_template('dashboard/company/transactables/client_actions')
    load_template('dashboard/company/transactables/form_actions')
    load_template('dashboard/layout/left_navigation')
    load_template('checkout/summary')
    load_template('checkout/sidebar')
  end

  def create_registration_screens!
    create_page!('Join Our Community')
    load_template('registrations/buyer_header')
    load_template('registrations/buyer_footer')
    load_template('registrations/seller_header')
    load_template('registrations/seller_footer')
  end

  def create_analytics!
    load_template('dashboard/company/analytics/show', false)
  end

  def create_custom_attribute(object, hash)
      hash = hash.with_indifferent_access
      attr = object.custom_attributes.where({
        name: hash.delete(:name)
      }).first_or_initialize
      attr.assign_attributes(hash)
      attr.set_validation_rules!
  end

  private

  def create_page!(name)
    slug = name.parameterize
    page = @instance.theme.pages.where(slug: slug).first_or_initialize
    page.path = name
    page.content = get_page_content("#{slug}.html")
    page.save
  end

  def load_template(path, partial = true)
    iv = InstanceView.where(
      instance_id: @instance.id,
      path: path,
    ).first_or_initialize
    iv.update!({
      transactable_types: TransactableType.all,
      body: read_template("#{path.gsub('/','_')}.liquid"),
      format: 'html',
      handler: 'liquid',
      partial: partial,
      view_type: 'view',
      locales: Locale.all
    })
  end

  def create_custom_attribute(object, hash)
      hash = hash.with_indifferent_access
      attr = object.custom_attributes.where({
        name: hash.delete(:name)
      }).first_or_initialize
      attr.assign_attributes(hash)
      attr.set_validation_rules!
  end

  def create_workflow_alerts
    Workflow.where(workflow_type: 'offer').destroy_all
    @offer_creator = Utils::DefaultAlertsCreator::OfferCreator.new.create_all!
    @sign_up_creator = Utils::DefaultAlertsCreator::SignUpCreator.new

    @sign_up_creator.create_guest_welcome_email!
    @sign_up_creator.create_host_welcome_email!
    @sign_up_creator.create_lister_onboarding_email!
    @sign_up_creator.create_enquirer_onboarding_email!

    @listing_creator = Utils::DefaultAlertsCreator::ListingCreator.new
    @listing_creator.create_notify_lister_of_cancellation!
    @listing_creator.create_notify_enquirer_of_completion!

    @user_message_creator = Utils::DefaultAlertsCreator::UserMessageCreator.new
    @user_message_creator.create_user_message_created!

    @order_item_creator = Utils::DefaultAlertsCreator::OrderItemCreator.new

    @order_item_creator.create_notify_enquirer_approved_order_item!
    @order_item_creator.create_notify_enquirer_rejected_order_item!
    @order_item_creator.create_notify_lister_created_order_item!

    Workflow.where(workflow_type: %w(request_for_quote reservation recurring_booking inquiry spam_report)).destroy_all
    WorkflowAlert.where(alert_type: 'sms').destroy_all
    alerts_to_be_destroyed = [ 'offer_mailer/notify_host_of_rejection' ]
    WorkflowAlert.where(template_path: alerts_to_be_destroyed).destroy_all

    create_email('post_action_mailer/host_sign_up_welcome')
    create_email('post_action_mailer/guest_sign_up_welcome')
    create_email('post_action_mailer/list')
    create_email('post_action_mailer/enquirer_onboarded')
    create_email('post_action_mailer/lister_onboarded')
    create_email('transactable_mailer/notify_lister_of_cancellation')
    create_email('transactable_mailer/notify_collaborators_of_cancellation')
    create_email('transactable_mailer/notify_enquirer_of_completion')
    create_email('offer_mailer/notify_guest_of_confirmation')
    create_email('offer_mailer/notify_host_of_cancellation_by_guest')
    create_email('offer_mailer/notify_guest_of_cancellation_by_guest')
    create_email('offer_mailer/notify_guest_with_confirmation')
    create_email('offer_mailer/notify_host_with_confirmation')
    create_email("user_message_mailer/notify_user_about_new_message")
    create_email('transactable_mailer/transactable_owner_added_collaborator_email')
    create_email('transactable_mailer/collaborator_declined')
    create_email('offer_mailer/notify_guest_of_rejection')
    create_email('order_item_mailer/notify_enquirer_approved_order_item')
    create_email('order_item_mailer/notify_enquirer_rejected_order_item')
    create_email('order_item_mailer/notify_lister_created_order_item')

  end

  private

  def read_template(name)
    File.read(File.join(Rails.root, 'lib', 'tasks', 'uot', 'templates', name))
  end

  def get_page_content(filename)
    File.read(File.join(Rails.root, 'lib', 'tasks', 'uot', 'pages', filename))
  end

  def create_email(path)
    body = File.read(File.join(Rails.root, 'lib', 'tasks', 'uot', 'templates', 'mailers', path + '.html.liquid'))
    iv = InstanceView.where(instance_id: @instance.id, view_type: 'email', path: path, handler: 'liquid', format: 'html', partial: false).first_or_initialize
    iv.locales = Locale.all
    iv.transactable_types = TransactableType.all
    iv.body = body
    iv.save!

    iv = InstanceView.where(instance_id: @instance.id, view_type: 'email', path: path, handler: 'liquid', format: 'text', partial: false).first_or_initialize
    iv.body = ActionView::Base.full_sanitizer.sanitize(body)
    iv.locales = Locale.all
    iv.transactable_types = TransactableType.all
    iv.save!
  end

end

