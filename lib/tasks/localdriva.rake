# frozen_string_literal: true
namespace :localdriva do
  desc 'Setup LocalDriva'
  task setup: :environment do
    @instance = Instance.find(211)
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
      wish_lists_enabled: true,
      default_currency: 'AUD',
      default_country: 'Australia',
      force_accepting_tos: true,
      user_blogs_enabled: true,
      force_fill_in_wizard_form: true,
    )
    @instance.save
    @instance.set_context!

    @default_profile_type = InstanceProfileType.find(617)
    @instance_profile_type = InstanceProfileType.find(619)
    @instance_profile_type.update_columns(
      onboarding: true,
      create_company_on_sign_up: true,
      # show_categories: true,
      # category_search_type: 'AND',
      searchable: true,
      search_only_enabled_profiles: true
    )

    setup = LocaldrivaSetup.new(@instance)
    setup.create_transactable_types!
    setup.create_custom_model!
    # setup.create_custom_attributes!
    # setup.create_categories!
    # setup.create_or_update_form_components!
    # setup.set_theme_options
    setup.create_content_holders
    setup.create_views
    setup.create_translations
    # setup.create_workflow_alerts
    setup.expire_cache
  end

  class LocaldrivaSetup
    def initialize(instance)
      @instance = instance
      @default_profile_type = InstanceProfileType.find(617)
      @instance_profile_type = InstanceProfileType.find(619)
      @transactable_type = TransactableType.find(807)
    end

    def create_custom_model!
      cmt = CustomModelType.where(instance_id: @instance.id, name: 'Languages').first_or_create!
      cmt.transactable_types = [@transactable_type]
      cmt.save!
      create_custom_attribute(cmt,         name: 'language',
                                           label: 'Language Spoken',
                                           attribute_type: 'string',
                                           html_tag: 'select',
                                           required: '1',
                                           public: true,
                                           searchable: false,
                                           valid_values: ['English', 'Chinese (Mandarin)', 'Spanish', 'German', 'French', 'Italian', 'Japanese', 'Korean', 'Arabic', 'Russian'])
      create_custom_attribute(cmt,         name: 'fluency',
                                           label: 'Fluency',
                                           attribute_type: 'string',
                                           html_tag: 'select',
                                           required: '1',
                                           public: true,
                                           searchable: false,
                                           valid_values: ['Basic', 'Fair', 'Fluent']
                                           )
    end

    def create_transactable_types!
      @transactable_type.attributes = {
        name: 'Booking',
        slug: 'booking',
        show_path_format: '/:transactable_type_id/:id',

        default_search_view: 'list',
        skip_payment_authorization: true,
        hours_for_guest_to_confirm_payment: 24,
        single_transactable: false,
        skip_location: true,
        bookable_noun: 'Booking',
        enable_photo_required: false,
        lessor: 'Passenger',
        lessee: 'Driver',
        enable_reviews: true,
        auto_accept_invitation_as_collaborator: true,
        require_transactable_during_onboarding: false,
        access_restricted_to_invited: true
      }

      @transactable_type.offer_action ||= @transactable_type.build_offer_action(
        enabled: true,
        cancellation_policy_enabled: '1',
        cancellation_policy_hours_for_cancellation: 24,
        cancellation_policy_penalty_hours: 1.5,
        service_fee_guest_percent: 0,
        service_fee_host_percent: 10
      )

      pricing = @transactable_type.offer_action.pricings.first_or_initialize
      pricing.attributes = {
        min_price_cents: 50_00,
        max_price_cents: 150_00,
        unit: 'hour',
        number_of_units: 1,
        order_class_name: 'Offer',
      }

      @transactable_type.save!
      pricing.save!
    end

    def create_custom_attributes!
    end

    def create_langauge_categories
      # root_category = Category.where(name: 'Languages').first_or_create!
      # root_category.transactable_types = TransactableType.all
      # root_category.instance_profile_types = [@instance_profile_type]
      # root_category.mandatory = true
      # root_category.multiple_root_categories = true
      # root_category.search_options = 'include'
      # root_category.save!

      # %w(English Spanish French German Japanese Korean Italian Polish Russian Other).each do |category|
      #   root_category.children.where(name: category).first_or_create!
      # end
    end



    def create_categories!
      # create_langauge_categories
    end

    def create_or_update_form_components!
      @transactable_type.form_components.destroy_all

      component = @transactable_type.form_components.where(form_type: 'space_wizard').first_or_initialize
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
      component.name = 'Add a Booking'
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
      CacheExpiration.send_expire_command 'Translation', instance_id: 211
      CacheExpiration.send_expire_command 'RebuildCustomAttributes'
      Rails.cache.clear
    end

    def create_views
      create_home_index!
      create_theme_header!
      # create_listing_show!
      create_theme_footer!
      # create_search_list!
      # create_user_profile!
      # create_my_cases!
      # create_wish_list_views!
      # create_registration_screens!
      # create_analytics!
      # create_static_pages!

      cleanup
    end

    def create_translations
      print 'Translating'
      transformation_hash = {
        'reservation' => 'bookings',
        'Reservation' => 'Bookings',
        'booking' => 'bookings',
        'Booking' => 'Bookings',
        'host' => 'Passenger',
        'seller' => 'Passenger',
        'Seller' => 'Passenger',
        'Host' => 'Passenger',
        'buyer' => 'driver',
        'Buyer' => 'driver',
        'guest' => 'driver',
        'Guest' => 'driver',
        'this listing' => 'your Booking',
        'that listing' => 'your Booking',
        'This listing' => 'Your Booking',
        'That listing' => 'Your Booking',
        'listing' => 'Booking',
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

      uot_locales = YAML.load_file(Rails.root.join('lib', 'tasks', 'localdriva', 'localdriva.en.yml'))
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
      load_template('home/homepage_content', true)
    end

    def create_theme_header!
      load_template('layouts/theme_header')
      # load_template('layouts/theme_dashboard_header')
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
      # create_page!('About Overview')
      # create_page!('Business Benefits')
      # create_page!('SME Benefits')
      # create_page!('Expertise')
      # create_page!('FAQ')
      # create_page!('Privacy Policy')
      # create_page!('Terms of Use')
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
      File.read(File.join(Rails.root, 'lib', 'tasks', 'localdriva', 'templates', name))
    end

    def get_page_content(filename)
      File.read(File.join(Rails.root, 'lib', 'tasks', 'localdriva', 'pages', filename))
    end

    def create_email(path)
      body = File.read(File.join(Rails.root, 'lib', 'tasks', 'localdriva', 'templates', 'mailers', path + '.html.liquid'))
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
