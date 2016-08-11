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
        'dashboard/user_bids': 1
      },
      skip_company: true,
      click_to_call: true
    )
    @instance.build_documents_upload(
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
      category_search_type: 'AND'
    )

    create_transactable_types!
    create_custom_attributes!
    create_categories!
    create_or_update_form_components!
    set_theme_options
    create_content_holders
    create_views
    create_translations
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
      auto_accept_invitation_as_collaborator: true
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
        name: 'company_name',
        label: 'Company Name',
        attribute_type: 'string',
        html_tag: 'input',
        required: "0",
        placeholder: 'Enter Full Name',
        public: true,
        searchable: false
    })
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
        valid_values: ["online", "on_site"],
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
        public: true,
        searchable: false
    })

    create_custom_attribute(@instance_profile_type, {
        name: 'workplace_type',
        label: 'Workplace Type',
        attribute_type: 'array',
        html_tag: 'check_box_list',
        required: "1",
        valid_values: ["online", "on_site"],
        public: true,
        searchable: true
    })

    create_custom_attribute(@instance_profile_type, {
        name: 'travel',
        label: 'Travel',
        attribute_type: 'string',
        html_tag: 'radio_buttons',
        required: "1",
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
        public: true,
        searchable: false
    })

    create_custom_attribute(@instance_profile_type, {
        name: 'discounts_available',
        label: 'Discounts available',
        attribute_type: 'string',
        html_tag: 'radio_buttons',
        required: "1",
        valid_values: ['available', 'not_available'],
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
    component.name = 'Add a Project'
    component.form_fields = [
      { "transactable" => "name" },
      { "transactable" => "project_contact" },
      { "transactable" => "company_name" },
      { "transactable" => "about_company" },
      { "transactable" => "description" },
      { "transactable" => "estimation" },
      { "transactable" => "workplace_type" },
      { "transactable" => "office_location" },
      { "transactable" => "Category - Languages" },
      { "transactable" => "budget" },
      { "transactable" => "deadline" }
    ]
    component.save!
    component = TransactableType.first.form_components.where(form_type: 'transactable_attributes').first_or_initialize
    component.name = 'Add a Project'
    component.form_fields = [
      { "transactable" => "name" },
      { "transactable" => "company_name" },
      { "transactable" => "about_company" },
      { "transactable" => "project_contact" },
      { "transactable" => "description" },
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
    theme.color_blue = '#4fc6e1'
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
      page.content = %Q{}
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
    CacheExpiration.send_expire_command 'InstanceView', instance_id: 198
    CacheExpiration.send_expire_command 'Translation', instance_id: 198
    CacheExpiration.send_expire_command 'CustomAttribute', instance_id: 198
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
    create_wish_list_button!
  end

  def create_translations

    @instance.translations.where(locale: 'en', key: 'transactable_type.project.labels.name').first_or_initialize.update!(value: 'Project Title')
    @instance.translations.where(locale: 'en', key: 'transactable_type.project.placeholders.name').first_or_initialize.update!(value: 'Enter Title')

    @instance.translations.where(locale: 'en', key: 'transactable_type.project.labels.description').first_or_initialize.update!(value: 'Vignette of a scope (describe the project)')
    @instance.translations.where(locale: 'en', key: 'transactable_type.project.placeholders.description').first_or_initialize.update!(value: 'Description, format of delivery, any other requirements')

    transformation_hash = {
      'reservation' => 'offer',
      'Reservation' => 'Offer',
      'booking' => 'offer',
      'Booking' => 'Offer',
      'host' => 'Client',
      'Host' => 'Client',
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
    @instance.translations.where(
      locale: 'en',
      key: 'sign_up_form.buyer_sign_up_to'
    ).first_or_initialize.update!(value: 'Sign Up for UoT')

    @instance.translations.where(
      locale: 'en',
      key: 'sign_up_form.seller_sign_up_to'
    ).first_or_initialize.update!(value: 'Create a Client Account')

    @instance.translations.where(
      locale: 'en',
      key: 'ui.header.list_your_thing'
    ).first_or_initialize.update!(value: 'Become a Client')

    @instance.translations.where(
      locale: 'en',
      key: 'registrations.accept_terms_of_service'
    ).first_or_initialize.update!(value: 'Yes, I understand and agree to <a href="/terms-of-use" target="_blank">Terms of Service</a> including the <a href="/user-agreement" target="_blank">User Agreement</a> and <a href="/privacy-policy" target="_blank">Privacy Policy</a>')

    @instance.translations.where(
      locale: 'en',
      key: 'onboarding_wizard.list_your'
    ).first_or_initialize.update!(value: 'Complete Your Project')

    @instance.translations.where(
      locale: 'en',
      key: 'dashboard.nav.user_reservations'
    ).first_or_initialize.update!(value: 'My Offers')

    @instance.translations.where(
      locale: 'en',
      key: 'dashboard.nav.reviews'
    ).first_or_initialize.update!(value: 'Ratings')

    @instance.translations.where(
      locale: 'en',
      key: 'dashboard.nav.host_reservations'
    ).first_or_initialize.update!(value: 'My Offers')

    @instance.translations.where(
      locale: 'en',
      key: 'dashboard.nav.edit'
    ).first_or_initialize.update!(value: 'Account')

    @instance.translations.where(
      locale: 'en',
      key: 'dashboard.nav.transactables'
    ).first_or_initialize.update!(value: 'My Projects')

    @instance.translations.where(
      locale: 'en',
      key: 'top_navbar.my_bookings'
    ).first_or_initialize.update!(value: 'My Offers')

    @instance.translations.where(
      locale: 'en',
      key: 'dashboard.user_reservations.reservation_placed_html'
    ).first_or_initialize.update!(value: 'Offer created: <span>%{date}</span>')

    @instance.translations.where(
      locale: 'en',
      key: 'dashboard.analytics.bookings'
    ).first_or_initialize.update!(value: 'Offers')

    @instance.translations.where(
      locale: 'en',
      key: 'homepage.search_field_placeholder.full_text'
    ).first_or_initialize.update!(value: 'General search...')

    create_translation!('dashboard.user_reservations.title_count', "Offers (%{count})")

    create_translation!('general.generic_lessee_term', "client")



    create_translation!('dashboard.host_reservations.no_unconfirmed_reservations', "You have no unconfirmed offers.")
    create_translation!('dashboard.host_reservations.no_confirmed_reservations', "You have no confirmed offers.")
    create_translation!('dashboard.host_reservations.no_archived_reservations', "You have no archived offers.")
    create_translation!('dashboard.host_reservations.no_overdue_reservations', "You have no overdue offers.")
    create_translation!('dashboard.host_reservations.no_reservations_promote_reservations', "You currently have no offers.")

    create_translation!('dashboard.analytics.no_reservations_yet', "You currently do not have any offers.")

    create_translation!('simple_form.labels.transactable.confirm_reservations', "Manually confirm offers")

    create_translation!('dashboard.nav.user_reservations_count_html', "My Offers <span>%{count}</span>")

    create_translation!('dashboard.analytics.columns.bookings', 'Offers')
    create_translation!('dashboard.analytics.total.bookings', "%{total} offers")

    create_translation!('dashboard.host_reservations.pending_confirmation', "You must confirm this offer within <strong>%{time_to_expiry}</strong> or it will expire.")

    create_translation!('dashboard.transactables.title.listings', "My Projects")
    create_translation!('dashboard.manage_listings.tab', "My Projects")

    create_translation!('dashboard.user_reservations.upcoming', "Offers Open")
    create_translation!('dashboard.user_reservations.archived', "Offers Closed")

    create_translation!('dashboard.host_reservations.unconfirmed', "Offers Pending")
    create_translation!('dashboard.host_reservations.confirmed', "Offers Open")
    create_translation!('dashboard.host_reservations.archived', "Offers Closed")

    create_translation!('reservations.states.unconfirmed', "Pending")
    create_translation!('reservations.states.confirmed', "Open")
    create_translation!('reservations.states.archived', "Closed")
    create_translation!('reservations.states.cancelled_by_guest', "Cancelled by Expert")
    create_translation!('reservations.states.cancelled_by_host', "Cancelled by Client")

    create_translation!('top_navbar.manage_bookable', "My Projects")
    create_translation!('top_navbar.bookings_received', "My Offers")
    create_translation!('reservations_review.heading', "Bid on Project")

    create_translation!('reservations_review.errors.whoops', "Whoops! We couldn't make that offer.")

    create_translation!('activemodel.errors.models.reservation_request.attributes.base.total_amount_changed', "Bid on Project")
    create_translation!('dashboard.items.new_listing_full', "Add new Project")

    create_translation!('reservations_review.disabled_buttons.request', "Bidding...")
    create_translation!('dashboard.transactables.view_html', "View Profile")

    create_translation!('buy_sell_market.products.labels.summary', "Overall Rating:")
    create_translation!('dashboard.items.delete_listing', "Delete Project")

    create_translation!('sign_up_form.link_to_buyer', "Become an Expert here")
    create_translation!('sign_up_form.link_to_seller', "Become a Client here")

    create_translation!('time.formats.short', "%l:%M %p")

    create_translation!('wish_lists.buttons.selected_state', "Remove Favorite")
    create_translation!('wish_lists.buttons.unselected_state', "Add to Favorites")

    create_translation!('flash_messages.space_wizard.space_listed', "Your Project has been submitted to the marketplace!")

    create_translation!('flash_messages.dashboard.locations.add_your_company', "Please complete your Project first.")
    create_translation!('flash_messages.dashboard.add_your_company', "Please complete your Project first.")
    create_translation!('buy_sell_market.checkout.labels.the_following_documents', "Please make an offer by submitting a proposal with scope of work and terms for client to review.  Please upload your PDF file here:")
    create_translation!('reservations_review.buttons.request', "SUBMIT OFFER")

  end

  def create_email(path, body)
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

  def create_sms(path, body)
    iv = InstanceView.where(instance_id: @instance.id, view_type: 'sms', path: path, handler: 'liquid', format: 'text', partial: false).first_or_initialize
    iv.locales = Locale.all
    iv.transactable_types = TransactableType.all
    iv.body = body
    iv.save!
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

  def create_custom_validators!
    cv = CustomValidator.where(field_name: 'mobile_number', validatable: InstanceProfileType.seller.first).first_or_initialize
    cv.required = "1"
    cv.save!

    cv = CustomValidator.where(field_name: 'mobile_number', validatable: InstanceProfileType.buyer.first).first_or_initialize
    cv.required = "1"
    cv.save!
  end


  def create_home_index!
    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'home/index'
    ).first_or_initialize
    iv.update!({
      transactable_types: TransactableType.all,
      body: read_template('home_index.liquid'),
      format: 'html',
      handler: 'liquid',
      partial: false,
      view_type: 'view',
      locales: Locale.all
    })
  end

  def create_theme_header!
    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'layouts/theme_header',
    ).first_or_initialize
    iv.update!({
      transactable_types: TransactableType.all,
      body: read_template('layouts_theme_header.liquid'),
      format: 'html',
      handler: 'liquid',
      partial: true,
      view_type: 'view',
      locales: Locale.all
    })
  end

  def create_listing_show!
    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'listings/show'
    ).first_or_initialize
    iv.update!({
      transactable_types: TransactableType.all,
      body: read_template('listings_show.liquid'),
      format: 'html',
      handler: 'liquid',
      partial: false,
      view_type: 'view',
      locales: Locale.all
    })
  end

  def create_theme_footer!
    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'layouts/theme_footer',
    ).first_or_initialize
    iv.update!({
      transactable_types: TransactableType.all,
      body: read_template('layouts_theme_footer.liquid'),
      format: 'html',
      handler: 'liquid',
      partial: true,
      view_type: 'view',
      locales: Locale.all
    })
  end

  def create_search_list!
    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'search/list',
    ).first_or_initialize
    iv.update!({
      transactable_types: TransactableType.all,
      body: read_template('search_list.liquid'),
      format: 'html',
      handler: 'liquid',
      partial: false,
      view_type: 'view',
      locales: Locale.all
    })
  end

  def create_user_profile!
    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'registrations/show',
    ).first_or_initialize
    iv.update!({
      transactable_types: TransactableType.all,
      body: read_template('registrations_show.liquid'),
      format: 'html',
      handler: 'liquid',
      partial: false,
      view_type: 'view',
      locales: Locale.all
    })
  end

  def create_wish_list_button!
    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'shared/components/wish_list_button',
    ).first_or_initialize
    iv.update!({
      transactable_types: TransactableType.all,
      body: read_template('shared_components_wish_list_button.liquid'),
      format: 'html',
      handler: 'liquid',
      partial: true,
      view_type: 'view',
      locales: Locale.all
    })
  end

  def create_my_cases!
    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'dashboard/offers/offer',
    ).first_or_initialize
    iv.update!({
      transactable_types: TransactableType.all,
      body: %Q{
<header>
  <div class='row'>
    <div class='col-sm-7'>
      {% if reservation.transactable != blank and reservation.transactable.deleted? != true %}
        <h2>
          <a href="{{ reservation.transactable.show_path }}">
            {% if reservation.transactable.name.size > 0 %}
              {{ reservation.transactable.name }}
            {% else %}
              {{ 'dashboard.host_reservations.show_listing_page' | t}}
            {% endif %}
          </a>

          {{ reservation.transactable.click_to_call_button }}
        </h2>
      {% else %}
        <h2>{{ 'dashboard.user_reservations.listing_deleted' | t }}</h2>
      {% endif %}
    </div>
    <div class='col-xs-5'>
      <div class='order-status'>
        {% if reservation.archived_at and reservation.state == 'confirmed' %}
          <span class='confirmed'>
            {{ "reservations.states.completed" | translate }}
          </span>
        {% else %}
          <span class='{{ reservation.state }}'>
            {{ 'reservations.states.' | append: reservation.state | translate }}
          </span>
        {% endif %}
      </div>
    </div>
  </div>
</header>


{% include 'dashboard/user_reservations/reservation_details', reservation: reservation, for_host: false %}

<div class='row'>
  {% if reservation.guest_notes != blank %}
    <div class='col-sm-3'>
      <h3>{{ 'dashboard.host_reservations.exclusive_price_guests_notes' | t }}</h3>
      <blockquote>{{ reservation.guest_notes }}</blockquote>
    </div>
  {% endif %}
  {% if reservation.payment_documents.size > 0 %}
    <div class='col-sm-6'>
      <h3>{{ 'dashboard.host_reservations.payment_documents' | t }}</h3>
      <ul class='payment-documents'>
        {% for pd in reservation.payment_documents %}
          <li>
            <a href='{{ pd.file_url }}' download=true>{{ pd.file_name }}</a>
          </li>
        {% endfor %}
      </ul>
    </div>
  {% endif %}
  {% if reservation.additional_line_items.size > 0 %}
    <div class='col-sm-3 right'>
      <h3>{{ 'dashboard.host_reservations.additional_charges' | t }}</h3>
      <ul class='payment-documents'>
        {% for ac in reservation.additional_line_items %}
          <li>
            {{ ac.name | append: ' - ' | append: ac.formatted_total_price }}
          </li>
        {% endfor %}
      </ul>
    </div>
  {% endif %}
</div>

<h2>Offer</h2>
{% if reservation.confirmed? %}
  <div class='row'>
    <div class='col-sm-2'>Client</div>
    <div class='col-sm-2'>Offer Date</div>
    <div class='col-sm-2'>Offer Status</div>
    <div class='col-sm-2'>Accepted Date</div>
  </div>
  <div class='row'>
    <div class='col-sm-2'>{{ reservation.company.name }}</div>
    <div class='col-sm-2'>{{ reservation.created_at | to_date | l: 'long' }}</div>
    <div class='col-sm-2'>{{ reservation.state }}</div>
    <div class='col-sm-2'>{{ reservation.confirmed_at | to_date | l: 'long' }}</div>
  </div>
  <hr/>
  <div class='row'>
      <a class="btn btn-info" href="{{ 'dashboard_order_path' | generate_url: reservation.id }}">{{ 'dashboard.user_reservations.approved_offer' | t}}</a>
      {% if platform_context.instance.enable_reply_button_on_host_reservations? %}
        {% if reservation.user_messages.size == 0 %}
          <a class="btn btn-info" data-modal="true" href="{{ 'new_reservation_user_message_path' | generate_url: reservation.id, skip: true }}">{{ 'dashboard.user_reservations.send_message' | t}}</a>
        {% else %}
          <a class="btn btn-info" data-modal="true" href="{{ 'dashboard_user_message_path' | generate_url: reservation.user_messages.first.id }}">{{ 'dashboard.user_reservations.send_message' | t}}</a>
        {% endif %}
      {% endif %}
      <a class="btn btn-info" href="{{ reservation.transactable.show_path }}">{{ 'dashboard.user_reservations.view_case' | t}}</a>
  </div>
{% elsif reservation.unconfirmed? %}
  <div class='row'>
    <div class='col-sm-2'>Offer Date</div>
    <div class='col-sm-2'>Offer Status</div>
    <div class='col-sm-2'>Offer Actions</div>
  </div>
  <div class='row'>
    <div class='col-sm-2'>{{ reservation.created_at | to_date | l: 'long' }}</div>
    <div class='col-sm-2'>{{ reservation.state }}</div>
    <div class='col-sm-2'>
      Edit Offer |
      <a href="#" onclick="$('form#cancel_reservation').submit()" data-disable-with="{{ 'general.processing' | t }}" >{{ 'general.cancel' | t }}</a>
    </div>
    <form class="edit_reservation" id="cancel_reservation" action="{{ 'user_cancel_dashboard_user_reservation_path' | generate_url: reservation.id }}" accept-charset="UTF-8" method="post">
      <input name="utf8" type="hidden" value="&#x2713;" />
      <input type="hidden" name="authenticity_token" value="{{ form_authenticity_token }}" />
    </form>
  </div>
{% endif %}
      },
      format: 'html',
      handler: 'liquid',
      partial: true,
      view_type: 'view',
      locales: Locale.all
    })
    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'dashboard/company/offers/offer',
    ).first_or_initialize
    iv.update!({
      transactable_types: TransactableType.all,
      body: %Q{
<header>
  <div class='row'>
    <div class='col-xs-7'>
      {% if reservation.transactable != blank and reservation.transactable.deleted? != true %}
        <h2>
          <a href="{{ reservation.transactable.show_path }}">
            {% if reservation.transactable.name.size > 0 %}
              {{ reservation.transactable.name }}
            {% else %}
              {{ 'dashboard.host_reservations.show_listing_page' | t}}
            {% endif %}
          </a>

          {{ reservation.transactable.click_to_call_button }}
        </h2>
      {% else %}
        <h2>{{ 'dashboard.user_reservations.listing_deleted' | t }}</h2>
      {% endif %}
    </div>
    <div class='col-xs-5'>
      <div class='order-status'>
        {% if reservation.archived_at and reservation.state == 'confirmed' %}
          <span class='confirmed'>
            {{ "reservations.states.completed" | translate }}
          </span>
        {% else %}
          <span class='{{ reservation.state }}'>
            {{ 'reservations.states.' | append: reservation.state | translate }}
          </span>
        {% endif %}
      </div>
    </div>
  </div>
</header>

<div class='row'>
  {% if reservation.guest_notes != blank %}
    <div class='col-sm-3'>
      <h3>{{ 'dashboard.host_reservations.exclusive_price_guests_notes' | t }}</h3>
      <blockquote>{{ reservation.guest_notes }}</blockquote>
    </div>
  {% endif %}
  {% if reservation.payment_documents.size > 0 %}
    <div class='col-sm-10'>
      <h3>Offers</h3>
      <div class="row">
        <div class="col-sm-3">Date</div>
        <div class="col-sm-4">File</div>
      </div>
        {% for pd in reservation.payment_documents %}
          <div class="row">
            <div class="col-sm-3">{{ pd.created_at | l: 'long' }}</div>
            <div class="col-sm-4"><a href='{{ pd.file_url }}' download="{{ pd.file_name }}">{{ pd.file_name }}</a></div>
          </div>
        {% endfor %}
    </div>
  {% endif %}
  {% if reservation.additional_line_items.size > 0 %}
    <div class='col-sm-3 right'>
      <h3>{{ 'dashboard.host_reservations.additional_charges' | t }}</h3>
      <ul class='payment-documents'>
        {% for ac in reservation.additional_line_items %}
          <li>
            {{ ac.name | append: ' - ' | append: ac.formatted_total_price }}
          </li>
        {% endfor %}
      </ul>
    </div>
  {% endif %}
</div>

<hr/>

{% if reservation.confirmed? and reservation.archived_at == blank %}
  <hr/>
  <div class='row'>
    <a class="btn btn-info" href="{{ 'dashboard_order_path' | generate_url: reservation.id }}">{{ 'dashboard.user_reservations.approved_offer' | t}}</a>
    {% if platform_context.instance.enable_reply_button_on_host_reservations? %}
      {% if reservation.user_messages.size == 0 %}
        <a class="btn btn-info" data-modal="true" href="{{ 'new_reservation_user_message_path' | generate_url: reservation.id, skip: true }}">{{ 'dashboard.user_reservations.send_message' | t}}</a>
      {% else %}
        <a class="btn btn-info" data-modal="true" href="{{ 'dashboard_user_message_path' | generate_url: reservation.user_messages.first.id }}">{{ 'dashboard.user_reservations.send_message' | t}}</a>
      {% endif %}
    {% endif %}
    <a class="btn btn-info" href="{{ reservation.transactable.show_path }}">{{ 'dashboard.user_reservations.view_case' | t}}</a>
    <a class="btn btn-info" href="#" onclick="$('form#archive_reservation').submit()" data-disable-with="{{ 'general.processing' | t }}" >{{ 'dashboard.user_reservations.close_case' | t }}</a>
  </div>
  <form class="edit_reservation" id="archive_reservation" action="{{ 'archive_dashboard_company_orders_received_path' | generate_url: reservation.id }}" accept-charset="UTF-8" method="post">
    <input name="utf8" type="hidden" value="&#x2713;" />
    <input type="hidden" name="authenticity_token" value="{{ form_authenticity_token }}" />
  </form>
{% endif %}

      },
      format: 'html',
      handler: 'liquid',
      partial: true,
      view_type: 'view',
      locales: Locale.all
    })

    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'dashboard/company/transactables/index',
    ).first_or_initialize
    iv.update!({
      transactable_types: TransactableType.all,
      body: %Q{
{% assign i18n_title = 'dashboard.transactables.manage' | translate %}
{% title i18n_title %}

{% capture is_client %}{% if current_user.buyer_profile == blank %}true{% else %}false{% endif %}{% endcapture %}
{% if is_client == 'true' %}
  {% assign role = 'lister' %}
{% else %}
  {% assign role = 'enquirer' %}
{% endif %}

{% if params.status != blank %}
  {% assign current_status = params.status  %}
{% else %}
  {% assign current_status = 'pending'  %}
{% endif %}

{% content_for 'page_header' %}
  <h1>
    My Projects > {{ current_status | humanize }}
  </h1>
  {% assign form_url = transactable_type.transactable_types_path %}

  {% form_for :transactable, url: @form_url, method: 'get', html-class: 'search', form_for_type: 'dashboard' %}
    <select name="filter[properties][workplace_type]">
      <option value="">Any</option>
      <option value="Online" {% if params.filter.properties.workplace_type == 'Online' %}selected{% endif%}>Workplace Online</option>
      <option value="On Site" {% if params.filter.properties.workplace_type == 'On Site' %}selected{% endif%}>Workplace On Site</option>
    </select>
    <select name="order_by">
      <option value="created_at desc">Newest</option>
      <option value="created_at asc" {% if params.order_by == 'created_at asc' %}selected{% endif%}>Oldest</option>
    </select>
    {% submit submit, class: 'hidden' %}
  {% endform_for %}

  {% if is_client == "true" %}
    <div class='options visible-sm visible-xs'>
      <a href='{{ transactable_type.new_transactable_path }}' class='btn btn-primary'>
        <span class='fa fa-plus'></span>
        {{ 'dashboard.items.new_listing_short' | translate }}
      </a>
    </div>
  {% endif %}
{% endcontent_for %}

{% content_for 'panel_navigation_links' %}
    <li class='{{ 'pending' | active_class:current_status }}'>
      <a href='{{ tt.transactable_types_path | append: "?status=pending" }}'>Projects Pending ({{ pending_transactables | total_entries }})</a>
    </li>
    <li class='{{ 'in progress' | active_class:current_status }}'>
      <a href='{{ tt.transactable_types_path | append: "?status=in progress" }}'>Projects In Progress ({{ in_progress_transactables | total_entries }})</a>
    </li>
    <li class='{{ 'archived' | active_class:current_status }}'>
      <a href='{{ tt.transactable_types_path | append: "?status=archived" }}'>Projects Archived ({{ archived_transactables | total_entries }})</a>
    </li>
{% endcontent_for %}

{% content_for 'panel_options' %}
  <div class='pull-right options {% if transactables.size > 0 %} additional-listing-options {% endif %}'>

    {% if is_client == 'true' %}
      <a href='{{ transactable_type.new_transactable_path }}' class='btn btn-primary navbar-btn'>
        <span class='fa fa-plus'></span>
        {{ 'dashboard.items.new_listing_full' | translate: type: transactable_type.bookable_noun_plural }}
      </a>
    </div>
  {% endif %}
{% endcontent_for %}

<nav class='panel-nav-mobile visibile-sm visible-xs' role='navigation'>
  {% dropdown_menu { label: transactable_type.bookable_noun_plural, wrapper_class: 'links' } %}
    {% yield 'panel_navigation_links' %}
  {% enddropdown_menu %}
</nav>

<nav class='panel-nav hidden-xs hidden-sm'>
  <ul class='tabs pull-left'>
    {% yield 'panel_navigation_links' %}
  </ul>
  {% yield 'panel_options' %}
</nav>

{% if current_status == 'pending' %}
  {% include 'dashboard/company/transactables/listing.html' transactables: pending_transactables, param_name: 'pending_page' %}
{% elsif current_status == 'in progress' %}
  {% include 'dashboard/company/transactables/listing.html' transactables: in_progress_transactables, param_name: 'in_progress_page' %}
{% elsif current_status == 'archived' %}
  {% include 'dashboard/company/transactables/listing.html' transactables: archived_transactables, param_name: 'archived_page' %}
{% endif %}
      },
      format: 'html',
      handler: 'liquid',
      partial: false,
      view_type: 'view',
      locales: Locale.all
    })

    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'dashboard/company/transactables/listing',
    ).first_or_initialize
    iv.update!({
      transactable_types: TransactableType.all,
      body: %Q{
<div class='panel'>
  <div class='panel-body'></div>

  {% if transactables.size > 0 %}
    {% if is_client == "true" %}
      {% include 'dashboard/company/transactables/client_listing.html' %}
    {% else %}
      {% include 'dashboard/company/transactables/sme_listing.html' %}
    {% endif %}
  {% else %}
    <p class='empty-resultset'>
      {{ 'dashboard.items.empty' | translate: name: transactable_type.bookable_noun_plural }}
    </p>
  {% endif %}
</div>

{% will_paginate collection: transactables, inner_window: 1, outer_window: 0, class: '', renderer: dashboard, param_name: @param_name %}
      },
      format: 'html',
      handler: 'liquid',
      partial: true,
      view_type: 'view',
      locales: Locale.all
    })

    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'dashboard/company/transactables/sme_actions',
    ).first_or_initialize
    iv.update!({
      transactable_types: TransactableType.all,
      body: %Q{
{% if transactable.user_messages.size == 0 %}
  <a class="btn btn-info" data-modal="true" href="{{ 'new_reservation_user_message_path' | generate_url: transactable.id, skip: true }}">Send Message</a>
{% else %}
  <a class="btn btn-info" data-modal="true" href="{{ 'dashboard_user_message_path' | generate_url: transactable.user_messages.first.id }}">Send Message</a>
{% endif %}

{{ transactable.creator.click_to_call_button }}

{% if can_make_offer == true %}
  <a class="btn btn-info" href="{{ 'new_dashboard_order_path' | generate_url: transactable_id: transactable.id }}">Make an Offer</a>
{% elsif current_status == 'in progress' %}
  In progress
{% endif %}

{% unless current_user.has_verified_merchant_account == true %}
  <p class="merchant-account-reminder">Before making any offer, you need to set up your <a href="{{ 'edit_dashboard_company_payouts_path' | generate_url: company.id }}">merchant account</a>.</p>
{% endunless %}

      },
      format: 'html',
      handler: 'liquid',
      partial: true,
      view_type: 'view',
      locales: Locale.all
    })

    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'dashboard/company/transactables/sme_listing',
    ).first_or_initialize
    iv.update!({
      transactable_types: TransactableType.all,
      body: %Q{
{% for transactable in transactables %}
  {% assign collaborator = current_user  | find_collaborator: transactable %}
  <article class="listing">
    <h2>{{ transactable.name }}</h2>
    <a href="{{ transactable.show_path }}">Project details</a>
    <div class="row">
      <div class="col-md-6">
        <p>Contact: {{ transactable.properties.project_contact }}</p>
        <p>Company: {{ transactable.properties.company_name }}</p>
        <p>Invite sent: {{ collaborator.approved_by_owner_at | to_date | l: 'short' }}</p>
        <p>Workplace: {{ transactable.properties.workplace_type }}</p>
        {% if transactable.properties.workplace_type == 'On Site' %}
          <p>Office: {{ transactable.properties.office_location }}</p>
        {% endif %}
      </div>
      <div class="col-md-6">
        <p>Approx. Budget: {{ transactable.properties.budget | pricify }}</p>
        <p>Deadline: {{ transactable.properties.deadline | to_date | l: 'short' }}</p>
        <p>Approx. Time to Complete: {{ transactable.properties.estimation }}</p>
      </div>
    </div>
    <h4>Project Description</h4>
    <p>{{ transactable.description }}</p>

    {% assign orders = current_user | get_enquirer_orders: transactable %}
    {% assign can_make_offer = false %}
    {% if current_status == 'pending' %}
      {% if orders == empty %}
        {% assign can_make_offer = true %}
      {% else %}
        {% assign can_make_offer = true %}
        {% for order in orders %}
          {% if order.state == 'unconfirmed' %}
            {% assign can_make_offer = false %}
          {% endif %}
        {% endfor %}
      {% endif  %}
    {% endif %}

    {% include 'dashboard/company/transactables/sme_actions.html' %}

    <hr>

    {% if orders != empty %}
      {% assign order = orders.last %}
      <h3>Offer</h3>
      <table>
        <thead>
          <tr>
            <th>Offer Made:</th>
            <th>Offer Status:</th>
            {% if order.unconfirmed? %}
              <th>Offer Action:</th>
            {% else %}
              <th>Date</th>
            {% endif %}
            {% if order.confirmed? %}
              <th>View offer</th>
            {% endif %}
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>{{ order.created_at | to_date | l: 'short' }}</td>
            <td>{{ 'reservations.states.' | append: order.state | t }}</td>
            {% if order.unconfirmed? %}
              <td>
                {% if order.unconfirmed? %}
                  <a href="{{ 'edit_dashboard_order_path' | generate_url: order.id }}">{{ 'general.edit' | t }}</a>
                {% endif %}
                {% if order.unconfirmed?  %}
                  <a href="{{ 'enquirer_cancel_dashboard_order_path' | generate_url: order.id }}" data-method="post" data-confirm="Are you sure?">{{ 'general.cancel' | t }}</a>
                {% endif %}
              </td>
            {% elsif order.confirmed? %}
              <td>{{ order.confirmed_at | l: 'long' }}</td>
            {% else %}
              <td>{{ order.archived_at | l: 'long' }}</td>
            {% endif %}
            {% if order.confirmed? %}
              <td><a href="{{ order.payment_documents[0].file_url }}" target="_blank">{{  order.payment_documents[0].file_name }}</a></td>
            {% endif %}
          </tr>
        </tbody>
      </table>
    {% endif %}

  </article>
{% endfor %}

      },
      format: 'html',
      handler: 'liquid',
      partial: true,
      view_type: 'view',
      locales: Locale.all
    })

    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'dashboard/company/transactables/client_listing',
    ).first_or_initialize
    iv.update!({
      transactable_types: TransactableType.all,
      body: %Q{
{% for transactable in transactables %}
  {% assign collaborator = current_user  | find_collaborator: transactable %}
  {% assign accepted_order = transactable.first_accepted_order %}
  <article class="listing">
    <h2>{{ transactable.name }}</h2>
    {% if current_status == 'archived' %}
      Completed
    {% else %}
      <a href="{{ transactable.show_path }}">Project details</a>
    {% endif %}
    <div class="row">
      <div class="col-md-6">
        <p>Workplace: {{ transactable.properties.workplace_type }}</p>
        {% if transactable.properties.workplace_type == 'On Site' %}
          <p>Office: {{ transactable.properties.office_location }}</p>
        {% endif %}
      </div>
      <div class="col-md-6">
        <p>Approx. Budget: {{ transactable.properties.budget | pricify }}</p>
        <p>Deadline: {{ transactable.properties.deadline | to_date | l: 'short' }}</p>
        <p>Approx. Time to Complete: {{ transactable.properties.estimation }}</p>
      </div>
    </div>
    <h4>Project Description</h4>
    <p>{{ transactable.description }}</p>

    {% include 'dashboard/company/transactables/client_actions.html' %}

    <hr>

    {% if current_status == "pending" %}
      {% assign transactable_collaborators = transactable.approved_transactable_collaborators %}
      {% if transactable_collaborators != empty %}
        <h3>SMEs Invited ({{ transactable_collaborators.size }})</h3>
        <table>
          <thead>
            <tr>
              <th>SMEs:</th>
              <th>Invite Date:</th>
              <th>Invite Action:</th>
            </tr>
          </thead>
          <tbody>
            {% for transactable_collaborator in transactable_collaborators %}
              <tr>
                <td>{{ transactable_collaborator.user.name }}</td>
                <td>{{ transactable_collaborator.approved_by_owner_at | to_date | l: 'short' }}</td>
                <td>
                  <a class="btn btn-info" data-modal="true" href="{{ transactable_collaborator.user.user_message_path }}">{{ 'dashboard.user_reservations.send_message' | t}}</a>

                  {{ transactable_collaborator.user.click_to_call_button }}

                  <a class="btn btn-info" href="{{ transactable_collaborator.destroy_path }}" data-method="delete" data-confirm="Are you sure?">Remove</a>

                </td>
              </tr>
            {% endfor %}
          </tbody>
        </table>
      {% endif %}

      {% assign orders = transactable.orders %}
      {% if orders != empty %}
        <h3>Offers ({{ orders.size }})</h3>
        <table>
          <thead>
            <tr>
              <th>SMEs:</th>
              <th>Offer Date:</th>
              <th>Offer Status:</th>
              <th>Offer Action:</th>
            </tr>
          </thead>
          <tbody>
            {% for order in orders %}
              <tr>
                <td>{{ order.user.name }}</td>
                <td>{{ order.created_at | to_date | l: 'short' }}</td>
                <td>{{ 'reservations.states.' | append: order.state | t }}</td>
                <td>
                  {% if order.unconfirmed? %}
                    <a href="{{ order.payment_documents[0].file_url }}" target="_blank">Review</a>
                    <a href="{{ order.rejection_form_path }}" data-modal="true">Reject</a>
                    <a href="{{ order.confirm_path }}" data-method="post" data-confirm="Are you sure?">Accept</a>
                  {% endif %}
                </td>
              </tr>
            {% endfor %}
          </tbody>
        </table>
      {% endif %}


    {% elsif current_status == "in progress" or current_status == "archived" %}
      <h3>Offer</h3>
      <table>
        <thead>
          <tr>
            <th>Offer Made</th>
            <th>Offer Status</th>
            <th>Date</th>
            <th>View Offer</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>{{ accepted_order.created_at | to_date | l: 'short' }}</td>
            <td>Accepted</td>
            <td>{{ accepted_order.confirmed_at | to_date | l: 'short' }}</td>
            <td><a href="{{ accepted_order.payment_documents[0].file_url }}" target="_blank">{{ accepted_order.payment_documents[0].file_name }}</a></td>
          </tr>
        </tbody>
      </table>

      <a href="#" class="btn btn-default">View Time & Expenses</a>
      {% if current_status == 'in progress' %}
        <a href="{{ accepted_order.complete_path }}" data-method="post" class="btn btn-default">Project Completed</a>
      {% else %}
        <p>Total Paid {{ order.total_amount | pricify: order.currency }}</p>
      {% endif %}
    {% endif %}

  </article>
{% endfor %}
      },
      format: 'html',
      handler: 'liquid',
      partial: true,
      view_type: 'view',
      locales: Locale.all
    })

    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'dashboard/company/transactables/client_actions',
    ).first_or_initialize
    iv.update!({
      transactable_types: TransactableType.all,
      body: %Q{
{% if current_status == 'pending' %}
  <a href='{{ transactable.edit_path }}'>Edit Project</a>
{% endif %}

{% if current_status != 'archived' %}
  <a href='{{ transactable.destroy_path }}' data-method="delete" data-confirm="Are you sure?">Cancel Project</a>
{% endif %}

{% if current_status == 'in progress' %}

  {% if accepted_order.user_messages.size == 0 %}
    <a class="btn btn-info" data-modal="true" href="{{ 'new_reservation_user_message_path' | generate_url: accepted_order.id, skip: true }}">{{ 'dashboard.user_reservations.send_message' | t}}</a>
  {% else %}
    <a class="btn btn-info" data-modal="true" href="{{ 'dashboard_user_message_path' | generate_url: accepted_order.user_messages.first.id }}">{{ 'dashboard.user_reservations.send_message' | t}}</a>
  {% endif %}

  {{ accepted_order.user.click_to_call_button }}

{% endif %}

      },
      format: 'html',
      handler: 'liquid',
      partial: true,
      view_type: 'view',
      locales: Locale.all
    })

    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'checkout/summary',
    ).first_or_initialize
    iv.update!({
      transactable_types: TransactableType.all,
      body: %Q{
<div></div>
      },
      format: 'html',
      handler: 'liquid',
      partial: true,
      view_type: 'view',
      locales: Locale.all
    })
    iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'checkout/sidebar',
    ).first_or_initialize
    iv.update!({
      transactable_types: TransactableType.all,
      body: %Q{
<div></div>
      },
      format: 'html',
      handler: 'liquid',
      partial: true,
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

  private

  def read_template(name)
    File.read(File.join(Rails.root, 'lib', 'tasks', 'uot_templates', name))
  end

end

