# frozen_string_literal: true
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

  class UotSetup
    def initialize(instance)
      @instance = instance
      @default_profile_type = InstanceProfileType.find(569)
      @instance_profile_type = InstanceProfileType.find(571)
    end

    def create_custom_model!
      cmt = CustomModelType.where(instance_id: @instance.id, name: 'Recommendations').first_or_create!
      cmt.instance_profile_types = [@instance_profile_type]
      cmt.save!
      create_custom_attribute(cmt,         name: 'recommendation',
                                           label: 'Recommendation',
                                           attribute_type: 'string',
                                           html_tag: 'textarea',
                                           required: '1',
                                           public: true,
                                           searchable: false)
      create_custom_attribute(cmt,         name: 'author',
                                           label: 'Author',
                                           attribute_type: 'string',
                                           html_tag: 'input',
                                           required: '1',
                                           public: true,
                                           searchable: false)
      cmt = CustomModelType.where(instance_id: @instance.id, name: 'Links').first_or_create!
      cmt.instance_profile_types = [@instance_profile_type]
      cmt.save!
      create_custom_attribute(cmt,         name: 'url_link',
                                           label: 'URL',
                                           attribute_type: 'string',
                                           html_tag: 'input',
                                           required: '1',
                                           public: true,
                                           searchable: false)
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
        lessor: 'Client',
        lessee: 'Expert',
        enable_reviews: true,
        auto_accept_invitation_as_collaborator: true,
        require_transactable_during_onboarding: false,
        access_restricted_to_invited: true
      }

      transactable_type.offer_action ||= transactable_type.build_offer_action(
        enabled: true,
        cancellation_policy_enabled: '1',
        cancellation_policy_hours_for_cancellation: 24,
        cancellation_policy_penalty_hours: 1.5,
        service_fee_guest_percent: 0,
        service_fee_host_percent: 30
      )

      pricing = transactable_type.offer_action.pricings.first_or_initialize
      pricing.attributes = {
        min_price_cents: 50_00,
        max_price_cents: 150_00,
        unit: 'hour',
        number_of_units: 1,
        order_class_name: 'Offer',
        allow_free_booking: true,
        allow_nil_price_cents: true
      }

      merchant_fee = transactable_type.merchant_fees.first_or_initialize
      merchant_fee.attributes = {
        name: "Finder's Fee",
        amount_cents: 10_000,
        currency: 'USD',
        commission_receiver: 'mpo'
      }

      transactable_type.save!
      pricing.save!

      merchant_fee.save!
      fc = transactable_type.reservation_type.form_components.first
      fc.name = 'Make an Offer'
      fc.form_fields = [{ 'reservation' => 'payment_documents' }]
      fc.save
    end

    def create_custom_attributes!
      @transactable_type = TransactableType.first
      create_custom_attribute(@transactable_type,           name: 'about_company',
                                                            label: 'About Company (short description)',
                                                            attribute_type: 'string',
                                                            html_tag: 'textarea',
                                                            placeholder: 'Description of company',
                                                            required: '1',
                                                            public: true,
                                                            searchable: false)
      create_custom_attribute(@transactable_type,           name: 'estimation',
                                                            label: 'Approx. Time Required to Complete',
                                                            attribute_type: 'string',
                                                            html_tag: 'input',
                                                            placeholder: 'Enter Amount (months, days, hours)',
                                                            required: '1',
                                                            public: true,
                                                            searchable: false)

      create_custom_attribute(@transactable_type,           name: 'workplace_type',
                                                            label: 'Workplace Type',
                                                            attribute_type: 'string',
                                                            html_tag: 'radio_buttons',
                                                            required: '1',
                                                            valid_values: ['Online', 'On Site'],
                                                            public: true,
                                                            searchable: true)

      create_custom_attribute(@transactable_type,           name: 'office_location',
                                                            label: 'Office Location',
                                                            attribute_type: 'string',
                                                            html_tag: 'input',
                                                            required: '0',
                                                            placeholder: 'Enter City or Area',
                                                            public: true,
                                                            searchable: false)
      create_custom_attribute(@transactable_type,           name: 'budget',
                                                            label: 'Approximate Value / Budget',
                                                            attribute_type: 'float',
                                                            html_tag: 'input',
                                                            placeholder: 'Enter Amount',
                                                            required: '0',
                                                            public: true,
                                                            searchable: false)
      create_custom_attribute(@transactable_type,           name: 'deadline',
                                                            label: 'Deadline',
                                                            attribute_type: 'date',
                                                            html_tag: 'input',
                                                            placeholder: 'yyyy-mm-dd',
                                                            hint: "Valid format for date is:\nyyyy-mm-dd",
                                                            required: '1',
                                                            public: true,
                                                            searchable: false)

      create_custom_attribute(@transactable_type,           name: 'type_of_deliverable',
                                                            label: 'Type of Deliverable',
                                                            attribute_type: 'string',
                                                            html_tag: 'textarea',
                                                            placeholder: '',
                                                            required: '0',
                                                            public: true,
                                                            searchable: false)

      create_custom_attribute(@transactable_type,           name: 'other_requirements',
                                                            label: 'Other Requirements',
                                                            attribute_type: 'string',
                                                            html_tag: 'textarea',
                                                            placeholder: '',
                                                            required: '0',
                                                            public: true,
                                                            searchable: false)

      create_custom_attribute(@transactable_type,           name: 'project_contact',
                                                            label: 'Project Contact',
                                                            attribute_type: 'string',
                                                            html_tag: 'input',
                                                            placeholder: 'Enter Full Name',
                                                            required: '0',
                                                            public: true,
                                                            searchable: false)

      create_custom_attribute(@instance_profile_type,           name: 'bio',
                                                                label: 'Bio',
                                                                attribute_type: 'string',
                                                                html_tag: 'textarea',
                                                                required: '1',
                                                                validation_only_on_update: true,
                                                                public: true,
                                                                searchable: false)

      create_custom_attribute(@instance_profile_type,           name: 'education',
                                                                label: 'Education, Certifications and Training',
                                                                attribute_type: 'string',
                                                                html_tag: 'textarea',
                                                                required: '0',
                                                                validation_only_on_update: true,
                                                                public: true,
                                                                searchable: false)

      create_custom_attribute(@instance_profile_type,           name: 'awards',
                                                                label: 'Awards and Honors',
                                                                attribute_type: 'string',
                                                                html_tag: 'textarea',
                                                                required: '0',
                                                                validation_only_on_update: true,
                                                                public: true,
                                                                searchable: false)

      create_custom_attribute(@instance_profile_type,           name: 'pro_service',
                                                                label: 'Professional Service',
                                                                attribute_type: 'string',
                                                                html_tag: 'textarea',
                                                                required: '0',
                                                                validation_only_on_update: true,
                                                                public: true,
                                                                searchable: false)

      create_custom_attribute(@instance_profile_type,           name: 'teaching',
                                                                label: 'Teaching, Writing and Publishing',
                                                                attribute_type: 'string',
                                                                html_tag: 'textarea',
                                                                required: '0',
                                                                validation_only_on_update: true,
                                                                public: true,
                                                                searchable: false)

      create_custom_attribute(@instance_profile_type,           name: 'employers',
                                                                label: 'Prior Employers or Clients',
                                                                attribute_type: 'string',
                                                                html_tag: 'textarea',
                                                                required: '0',
                                                                validation_only_on_update: true,
                                                                public: true,
                                                                searchable: false)

      create_custom_attribute(@instance_profile_type,           name: 'accomplishments',
                                                                label: 'Special Projects and Accomplishments ',
                                                                attribute_type: 'string',
                                                                html_tag: 'textarea',
                                                                required: '0',
                                                                validation_only_on_update: true,
                                                                public: true,
                                                                searchable: false)

      create_custom_attribute(@instance_profile_type,           name: 'giving_back',
                                                                label: 'Community and Giving Back Interests',
                                                                attribute_type: 'string',
                                                                html_tag: 'textarea',
                                                                required: '0',
                                                                validation_only_on_update: true,
                                                                public: true,
                                                                searchable: false)

      create_custom_attribute(@instance_profile_type,           name: 'hobbies',
                                                                label: 'Brief Personal Details (Family and Hobbies)',
                                                                attribute_type: 'string',
                                                                html_tag: 'textarea',
                                                                required: '0',
                                                                validation_only_on_update: true,
                                                                public: true,
                                                                searchable: false)

      create_custom_attribute(@instance_profile_type,           name: 'workplace_type',
                                                                label: 'Workplace Type',
                                                                attribute_type: 'array',
                                                                html_tag: 'check_box_list',
                                                                required: '0',
                                                                validation_only_on_update: true,
                                                                valid_values: ['Online', 'On Site'],
                                                                public: true,
                                                                searchable: true)

      create_custom_attribute(@instance_profile_type,           name: 'travel',
                                                                label: 'Travel',
                                                                attribute_type: 'string',
                                                                html_tag: 'radio_buttons',
                                                                required: '1',
                                                                validation_only_on_update: true,
                                                                valid_values: %w(yes no),
                                                                public: true,
                                                                searchable: true)

      create_custom_attribute(@instance_profile_type,           name: 'hourly_rate_decimal',
                                                                label: 'Hourly rate',
                                                                attribute_type: 'decimal',
                                                                html_tag: 'input',
                                                                required: '1',
                                                                validation_only_on_update: true,
                                                                public: true,
                                                                searchable: false)

      create_custom_attribute(@instance_profile_type,           name: 'discounts_available',
                                                                label: 'Discounts available',
                                                                attribute_type: 'string',
                                                                html_tag: 'radio_buttons',
                                                                validation_only_on_update: true,
                                                                required: '0',
                                                                valid_values: ['Available', 'Not Available'],
                                                                public: true,
                                                                searchable: false)

      create_custom_attribute(@instance_profile_type,           name: 'discounts_description',
                                                                label: 'What kind of discounts do you offer?',
                                                                attribute_type: 'string',
                                                                html_tag: 'input',
                                                                required: '0',
                                                                public: true,
                                                                searchable: false)

      create_custom_attribute(@instance_profile_type,           name: 'availability',
                                                                label: 'Availability',
                                                                attribute_type: 'string',
                                                                hint: 'Describe your availability to take projects. e.g. I am available to take projects on part time from Monday through Thursday every week.',
                                                                html_tag: 'input',
                                                                required: '0',
                                                                public: true,
                                                                searchable: false)

      create_custom_attribute(@instance_profile_type,           name: 'linkedin_url',
                                                                label: 'LinkedIn URL',
                                                                attribute_type: 'string',
                                                                html_tag: 'input',
                                                                required: '1',
                                                                validation_only_on_update: true,
                                                                public: true,
                                                                searchable: false)

      create_custom_attribute(@instance_profile_type,           name: 'cities',
                                                                label: 'In what cities you are willing to work?',
                                                                attribute_type: 'string',
                                                                html_tag: 'input',
                                                                required: '0',
                                                                public: true,
                                                                searchable: false)

      @lister_instance_profile_type = InstanceProfileType.find(570)

      cv = @lister_instance_profile_type.custom_validators.where(field_name: 'mobile_number').first_or_initialize
      cv.required = '1'
      cv.validation_only_on_update = true
      cv.save!

      cv = @default_profile_type.custom_validators.where(field_name: 'avatar').first_or_initialize
      cv.required = '1'
      cv.validation_only_on_update = true
      cv.save!

      create_custom_attribute(@lister_instance_profile_type,           name: 'linkedin_url',
                                                                       label: 'LinkedIn URL',
                                                                       attribute_type: 'string',
                                                                       html_tag: 'input',
                                                                       required: '1',
                                                                       validation_only_on_update: true,
                                                                       public: true,
                                                                       searchable: false)

      create_custom_attribute(@lister_instance_profile_type,           name: 'referred_by',
                                                                       label: 'Referred By',
                                                                       attribute_type: 'string',
                                                                       html_tag: 'input',
                                                                       required: '0',
                                                                       public: true,
                                                                       searchable: false)
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

      root_category.children.destroy_all if root_category.children.count > 3

      {
        'Government' => ['Civilian Government', 'Defense and Intelligence', 'Law Enforcement and Homeland Security', 'State and Local Government'],
        'Health and Life Sciences' => ['Health Plans', 'Healthcare Providers', 'Life Sciences, Biotechnology, & Pharmaceutical'],
        'Technology' => ['Oversight and Decision Support', 'Management and Operations']
      }.each_pair do |cat, subs|
        parent = root_category.children.where(name: cat).first_or_create!
        subs.each do |sub|
          parent.children.where(name: sub).first_or_create!
        end
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

      {
        'Management' => {
          'Growth' => ['Globalization, International & Emerging Markets', 'Business Development', 'Marketing, Branding, Communications, Social Media & Digital Engagement', 'Packaging and Pricing', 'Procurement, Government Contracting, Vehicles & RFPs', 'Sales Forecasting and Execution'],
          'Organization' => ['Advisory', 'Business Disruption and Digital Transformation', 'Business Turnarounds', 'Innovation', 'Leadership', 'M&A and Divestitures', 'Small Business, Start-ups & Entrepreneurship', 'Strategy'],
          'Operations' => ['Financial, Revenue Management & Tax', 'Governance, Policy, and Standards', 'HR, Culture, Diversity and Inclusion', 'Legal, Compliance & Regulatory', 'Operations, Efficiency, People & Organization', 'Organizational Change Management', 'Postmerger Integration']
        },
        'Information Technology' => {
          'Oversight and Decision Support' => ['Analytics', 'Architecture and Methodologies', 'Assessments', 'Big Data', 'Database Analysis and Design', 'IoT'],
          'Management and Operations' => ['Cloud & Hosting', 'CRM', 'Documentation and Technical Writing', 'Mainframe Environment', 'Operating Systems', 'Operations and Productivity', 'Program Management', 'Programming & Assembly Languages', 'Quality and Testing', 'Rapid Prototyping', 'Security, Privacy & Cyber Risk', 'Software Design, Development & Integration', 'Supply Chain, PLM, Manufacturing & ERP', 'Technology Infrastructure', 'Training', 'Usability and user experience']
        }
      }.each_pair do |cat, subs|
        parent1 = root_category.children.where(name: cat).first_or_create!
        subs.each_pair do |cat, subs|
          parent2 = parent1.children.where(name: cat).first_or_create!
          subs.each do |sub|
            parent2.children.where(name: sub).first_or_create!
          end
        end
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
      component.name = 'Fill out the information below'
      component.form_fields = [
        { 'company' => 'name' },
        { 'user' => 'current_address' },
        { 'user' => 'mobile_phone' },
        { 'seller' => 'linkedin_url' },
        { 'user' => 'avatar' },
        { 'user' => 'referred_by' }
      ]
      component.save!
      component = TransactableType.first.form_components.where(form_type: 'transactable_attributes').first_or_initialize
      component.name = 'Add a Project'
      component.form_fields = [
        { 'transactable' => 'price' },
        { 'transactable' => 'pro_bono' },
        { 'transactable' => 'name' },
        { 'transactable' => 'about_company' },
        { 'transactable' => 'project_contact' },
        { 'transactable' => 'description' },
        { 'transactable' => 'type_of_deliverable' },
        { 'transactable' => 'other_requirements' },
        { 'transactable' => 'estimation' },
        { 'transactable' => 'deadline' },
        { 'transactable' => 'workplace_type' },
        { 'transactable' => 'office_location' },
        { 'transactable' => 'Category - Languages' },
        { 'transactable' => 'budget' }

      ]
      component.save!
      component = @default_profile_type.form_components.where(form_type: 'instance_profile_types').first_or_initialize
      component.form_fields = [
        { 'buyer' => 'enabled' },
        { 'user' => 'name' },
        { 'user' => 'avatar' },
        { 'user' => 'email' },
        { 'user' => 'current_address' },
        { 'user' => 'mobile_phone' },
        { 'buyer' => 'linkedin_url' },
        { 'buyer' => 'hourly_rate_decimal' },
        { 'buyer' => 'workplace_type' },
        { 'buyer' => 'discounts_available' },
        { 'buyer' => 'discounts_description' },
        { 'buyer' => 'travel' },
        { 'buyer' => 'cities' },
        { 'buyer' => 'Category - Area Of Expertise' },
        { 'buyer' => 'Category - Industry' },
        { 'buyer' => 'Category - Languages' },
        { 'buyer' => 'bio' },
        { 'buyer' => 'education' },
        { 'buyer' => 'awards' },
        { 'buyer' => 'pro_service' },
        { 'buyer' => 'teaching' },
        { 'buyer' => 'Custom Model - Links' },
        { 'buyer' => 'employers' },
        { 'buyer' => 'accomplishments' },
        { 'buyer' => 'giving_back' },
        { 'buyer' => 'hobbies' },
        { 'buyer' => 'availability' },
        { 'buyer' => 'tags' },
        { 'buyer' => 'Custom Model - Recommendations' },
        { 'seller' => 'linkedin_url' },
        { 'seller' => 'company_name' },
        { 'user' => 'password' }
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

      theme.phone_number = '1-888-893-0705'
      theme.contact_email = 'info@UpsideOfTalent.com'
      theme.support_email = 'info@UpsideOfTalent.com'

      theme.facebook_url = 'https://www.facebook.com/UpsideOfTalent'
      theme.twitter_url = 'https://twitter.com/UpsideOfTalent'
      theme.gplus_url = 'https://plus.google.com/102635346315218116617'
      theme.instagram_url = 'https://www.instagram.com'
      theme.youtube_url = 'https://www.youtube.com/channel/UChQrYDFiI79ViMy98FeulkQ'
      theme.blog_url = '/blog'
      theme.linkedin_url = 'https://www.linkedin.com/company/upside-of-talent-llc'

      theme.remote_favicon_image_url = 'https://d2rw3as29v290b.cloudfront.net/instances/195/uploads/ckeditor/picture/data/2760/favicon.png'
      theme.remote_icon_retina_image_url = 'https://d2rw3as29v290b.cloudfront.net/instances/195/uploads/ckeditor/picture/data/2761/apple-touch-icon-60_2x.png'

      theme.updated_at = Time.now
      theme.save!
    end

    def create_content_holders
      ch = @instance.theme.content_holders.where(
        name: 'HEAD links and scripts'
      ).first_or_initialize

      ch.update!(content: read_template('head.liquid'),
                 inject_pages: ['any_page'],
                 position: 'head_bottom')

      ch = @instance.theme.content_holders.where(
        name: 'BODY end scripts'
      ).first_or_initialize

      ch.update!(content: read_template('body_end.liquid'),
                 inject_pages: ['any_page'],
                 position: 'body_bottom')
    end

    def expire_cache
      CacheExpiration.send_expire_command 'RebuildInstanceView'
      CacheExpiration.send_expire_command 'Translation', instance_id: 195
      CacheExpiration.send_expire_command 'RebuildCustomAttributes'
      Rails.cache.clear
    end

    def create_views
      create_home_index!
      create_admin_templates!
      create_theme_header!
      create_listing_show!
      create_theme_footer!
      create_search_list!
      create_user_profile!
      create_my_cases!
      create_wish_list_views!
      create_registration_screens!
      create_analytics!
      create_static_pages!

      cleanup
    end

    def create_translations
      print 'Translating'
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
        'listing' => 'Project',
        'free' => 'Pro Bono'
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
          next unless value != new_value
          t = Translation.find_or_initialize_by(locale: 'en', key: key, instance_id: @instance.id)
          t.value = new_value
          t.skip_expire_cache = true
          t.save!
          print '.'
          $stdout.flush
        end
      end

      uot_locales = YAML.load_file(Rails.root.join('lib', 'tasks', 'uot', 'uot.en.yml'))
      uot_locales_hash = convert_hash_to_dot_notation(uot_locales['en'])

      uot_locales_hash.each_pair do |key, value|
        create_translation!(key, value)
        print '.'
        $stdout.flush
      end
      puts ''
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
          ret.merge! convert_hash_to_dot_notation(v, key + '.')
        else
          ret[key] = v
        end
      end
    end

    def create_home_index!
      load_template('home/index', false)
    end

    def create_admin_templates!
      load_template('instance_admin/manage/orders/index', false)
      load_template('instance_admin/manage/orders/show', false)
    end

    def create_theme_header!
      load_template('layouts/theme_header')
      load_template('layouts/theme_dashboard_header')
      load_template('blog/blog_posts/header')
    end

    def create_listing_show!
      load_template('listings/show', false)
    end

    def create_theme_footer!
      load_template('layouts/theme_footer')
    end

    def create_search_list!
      load_template('search/list', false)
      load_template('search/basic_search')
      load_template('search/advanced_search')
    end

    def create_user_profile!
      load_template('registrations/show', false)
      load_template('registrations/edit_options')
      load_template('registrations/blog/blog_post')
      load_template('registrations/blog/show', false)
      load_template('dashboard/company/users/collaborations_for_current_user', false)
      load_template('dashboard/company/transactable_collaborators/transactable_collaborator')
      load_template('registrations/blog/social_buttons', true)
    end

    def create_wish_list_views!
      load_template('dashboard/wish_list_items/wish_list_item')
      load_template('shared/components/wish_list_button')
    end

    def create_my_cases!
      load_template('dashboard/offers/offer')
      # load_template('dashboard/order_items/project_info')
      load_template('dashboard/company/offers/offer')
      load_template('dashboard/company/transactables/index', false)
      load_template('dashboard/company/transactables/listing')
      load_template('dashboard/company/transactables/sme_actions')
      load_template('dashboard/company/transactables/sme_listing')
      load_template('dashboard/company/transactables/client_listing')
      load_template('dashboard/company/transactables/client_actions')
      load_template('dashboard/company/transactables/form_actions')
      load_template('listings/reservations/confirm_reservations')
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

    def create_static_pages!
      create_page!('About Overview')
      create_page!('Business Benefits')
      create_page!('SME Benefits')
      create_page!('Expertise')
      create_page!('FAQ')
      create_page!('Privacy Policy')
      create_page!('Terms of Use')
    end

    def create_analytics!
      load_template('dashboard/company/analytics/show', false)
      load_template('dashboard/company/transfers/show', false)
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
      @listing_creator.create_notify_collaborators_of_cancellation!

      @user_message_creator = Utils::DefaultAlertsCreator::UserMessageCreator.new
      @user_message_creator.create_user_message_created!

      @order_item_creator = Utils::DefaultAlertsCreator::OrderItemCreator.new

      @order_item_creator.create_notify_enquirer_approved_order_item!
      @order_item_creator.create_notify_enquirer_rejected_order_item!
      @order_item_creator.create_notify_lister_created_order_item!

      Utils::DefaultAlertsCreator::CollaboratorCreator.new.create_all!

      Workflow.where(workflow_type: %w(request_for_quote reservation recurring_booking inquiry spam_report)).destroy_all
      WorkflowAlert.where(alert_type: 'sms').destroy_all
      alerts_to_be_destroyed = ['offer_mailer/notify_host_of_rejection']
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
      create_email('offer_mailer/notify_host_of_confirmation')
      create_email('user_message_mailer/notify_user_about_new_message')
      create_email('transactable_mailer/transactable_owner_added_collaborator_email')
      create_email('transactable_mailer/collaborator_declined')
      create_email('offer_mailer/notify_guest_of_rejection')
      create_email('order_item_mailer/notify_enquirer_approved_order_item')
      create_email('order_item_mailer/notify_enquirer_rejected_order_item')
      create_email('order_item_mailer/notify_lister_created_order_item')
    end

    def cleanup
      destroy_page!('About')
      destroy_page!('How It Works')
    end

    private

    def create_custom_attribute(object, hash)
      hash = hash.with_indifferent_access
      attr = object.custom_attributes.where(name: hash.delete(:name)).first_or_initialize
      attr.assign_attributes(hash)
      attr.set_validation_rules!
    end

    def create_page!(name)
      slug = name.parameterize
      page = @instance.theme.pages.where(slug: slug).first_or_initialize
      page.path = name
      page.content = get_page_content("#{slug}.html")
      page.save
    end

    def destroy_page!(name)
      slug = name.parameterize
      page = @instance.theme.pages.where(slug: slug).first
      page&.destroy
    end

    def load_template(path, partial = true)
      iv = InstanceView.where(
        instance_id: @instance.id,
        path: path
      ).first_or_initialize
      iv.update!(transactable_types: TransactableType.all,
                 body: read_template("#{path.tr('/', '_')}.liquid"),
                 format: 'html',
                 handler: 'liquid',
                 partial: partial,
                 view_type: 'view',
                 locales: Locale.all)
    end

    def create_custom_attribute(object, hash)
      hash = hash.with_indifferent_access
      custom_attribute = object.custom_attributes.where(name: hash.delete(:name)).first_or_initialize
      custom_attribute.custom_validators.destroy_all
      custom_attribute.assign_attributes(hash)
      custom_attribute.save!
      custom_attribute.custom_validators.each(&:save!)
    end

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
end
