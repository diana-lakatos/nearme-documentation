require 'yaml'
require 'benchmark'

namespace :volte do

  desc 'Setup Volte'
  task setup: :environment do

    time = Benchmark.realtime do

      @instance = Instance.find(194)
      @instance.allowed_countries = ['Australia']
      @instance.default_country = 'Australia'
      @instance.allowed_currencies = ['AUD']
      @instance.default_currency = 'AUD'
      @instance.time_zone = 'Sydney'
      @instance.force_accepting_tos = true
      @instance.skip_company = true
      @instance.wish_lists_enabled = true
      @instance.save!
      @instance.set_context!

      setup = VolteSetup.new(@instance, File.join(Rails.root, 'lib', 'tasks', 'volte'))
      setup.create_transactable_types!
      setup.create_custom_attributes!
      setup.create_categories!
      setup.create_or_update_form_components!

      setup.set_theme_options
      setup.create_content_holders
      setup.create_liquid_views
      # setup.create_mailers
      # setup.create_smses
      setup.create_pages
      setup.create_translations

      setup.create_workflow_alerts
      setup.expire_cache
    end

    puts "\nDone in #{time.round(2)}s\n\n"
  end

  class VolteSetup

    def initialize(instance, theme_path)
      @instance = instance
      @theme_path = theme_path
      @default_profile_type = InstanceProfileType.find(566)
    end

    def create_transactable_types!
      @instance.transactable_types.where(name: 'Fashion Item').destroy_all

      transactable_type = @instance.transactable_types.where(name: 'Item').first_or_initialize
      transactable_type.attributes = {
        name: 'Item',
        slug: 'item',
        show_path_format: '/:transactable_type_id/:id',

        default_search_view: 'list',
        skip_payment_authorization: true,
        hours_for_guest_to_confirm_payment: 24,
        single_transactable: false,
        show_price_slider: true,
        skip_location: false,
        show_categories: true,
        category_search_type: 'OR',
        bookable_noun: 'Item',
        enable_photo_required: true,
        lessor: 'Lender',
        lessee: 'Borrower',
        enable_reviews: true,
        require_transactable_during_onboarding: true
      }

      transactable_type.time_based_booking ||= transactable_type.build_time_based_booking(
        enabled: true,
        cancellation_policy_enabled: "1",
        cancellation_policy_hours_for_cancellation: 24, #RT to confirm
        cancellation_policy_penalty_percentage: 30, #RT to confirm
        service_fee_guest_percent: 0,
        service_fee_host_percent: 15,
      )

      transactable_type.time_based_booking.pricings.where(unit: 'day', number_of_units: 4).first_or_initialize
      transactable_type.time_based_booking.pricings.where(unit: 'day', number_of_units: 8).first_or_initialize
      transactable_type.time_based_booking.pricings.where(unit: 'day', number_of_units: 30).first_or_initialize

      transactable_type.save!
      transactable_type.time_based_booking.save!

      fc = transactable_type.reservation_type.form_components.first
      fc.name = 'Request Item'
      fc.form_fields = [
        {'reservation' => 'payment_documents'},
        {'reservation' => 'dates'},
        {'reservation' => 'price'}
      ]
      fc.save
    end


    def create_custom_attributes!
      @transactable_type = TransactableType.first
      @transactable_type.custom_attributes.where(name: 'item_comments').destroy_all

      create_custom_attribute(@transactable_type, {
        name: 'item_type',
        label: 'Item Type',
        attribute_type: 'string',
        html_tag: 'select',
        required: "0",
        public: true,
        valid_values: ['Dress', 'Bag', 'Millinery', 'Outerwear', 'Accessories'],
        searchable: true,
        input_html_options: { 'data-show-field' => 'value-dependent' }
      })

      create_custom_attribute(@transactable_type, {
        name: 'item_style_bag',
        label: 'Item Style',
        attribute_type: 'string',
        html_tag: 'select',
        required: "0",
        public: true,
        valid_values: ['Clutch', 'Hobo', 'Mini bags', 'Satchels', 'Shoulder Bags', 'Totes', 'Wallets'],
        searchable: true,
        wrapper_html_options: { 'data-visibility-dependent' => 'bag' }
      })

      create_custom_attribute(@transactable_type, {
        name: 'item_style_milinery',
        label: 'Item Style',
        attribute_type: 'string',
        html_tag: 'select',
        required: "0",
        public: true,
        valid_values: ['Fascinator', 'Hat'],
        searchable: true,
        wrapper_html_options: { 'data-visibility-dependent' => 'milinery' }
      })

      create_custom_attribute(@transactable_type, {
        name: 'item_style_outerwear',
        label: 'Item Style',
        attribute_type: 'string',
        html_tag: 'select',
        required: "0",
        public: true,
        valid_values: ["Blazer", "Coat", "Denim", "Leather", "Fur"],
        searchable: true,
        wrapper_html_options: { 'data-visibility-dependent' => 'outerwear' }
      })

      create_custom_attribute(@transactable_type, {
        name: 'item_style_dress',
        label: 'Item Style',
        attribute_type: 'string',
        html_tag: 'select',
        required: "0",
        public: true,
        valid_values: ['Bridesmaid', 'Formal', 'Races', 'Wedding', 'Guest', 'Cocktail',
          'Work Function', 'Daytime', 'Mother of the Bride', 'Evening', 'Ball',
          'Maternity', 'Bridal', 'Black Tie'
        ],
        searchable: true,
        wrapper_html_options: { 'data-visibility-dependent' => 'dress' }
      })

      create_custom_attribute(@transactable_type, {
        name: 'item_style_accessories',
        label: 'Item Subtype',
        attribute_type: 'string',
        html_tag: 'select',
        required: "0",
        public: true,
        valid_values: ['Necklace', 'Belt', 'Other'],
        searchable: true,
        wrapper_html_options: { 'data-visibility-dependent' => 'accessories' }
      })


      create_custom_attribute(@transactable_type, {
        name: 'dress_size',
        label: 'Dress Size',
        attribute_type: 'string',
        html_tag: 'select',
        required: "0",
        public: true,
        valid_values: ["One size", "6", "8", "10", "12", "14", "16", "18", "20"],
        searchable: true,
        wrapper_html_options: { 'data-visibility-dependent' => 'dress' }
      })

      create_custom_attribute(@transactable_type, {
        name: 'milinery_size',
        label: 'Milinery Size',
        attribute_type: 'string',
        html_tag: 'select',
        required: "0",
        public: true,
        valid_values: ["One size", "Small", "Medium", "Large"],
        searchable: true,
        wrapper_html_options: { 'data-visibility-dependent' => 'milinery' }
      })

      create_custom_attribute(@transactable_type, {
        name: 'outerwear_size',
        label: 'Outerwear Size',
        attribute_type: 'string',
        html_tag: 'select',
        required: "0",
        public: true,
        valid_values: ["One size", "6", "8", "10", "12", "14", "16", "18", "20"],
        searchable: true,
        wrapper_html_options: { 'data-visibility-dependent' => 'outerwear' }
      })

      create_custom_attribute(@transactable_type, {
        name: 'dress_length',
        label: 'Dress Length',
        attribute_type: 'string',
        html_tag: 'select',
        required: "0",
        public: true,
        valid_values: ["Mini", "Knee Length", "Midi", "Floor Length"],
        searchable: true,
        wrapper_html_options: { 'data-visibility-dependent' => 'dress' }
      })

      create_custom_attribute(@transactable_type, {
        name: 'color',
        label: 'Color',
        attribute_type: 'string',
        html_tag: 'select',
        required: "0",
        public: true,
        valid_values: [
          "Black", "Brown", "Blue", "Cream", "Gold", "Green", "Grey", "Navy", "Orange", "Pink",
          "Print", "Purple ", "Red", "Silver", "White", "Yellow", "Assign your own color"
        ],
        searchable: true
      })

      create_custom_attribute(@transactable_type, {
        name: 'designer_name',
        label: 'Item Designer',
        attribute_type: 'string',
        html_tag: 'select',
        required: "0",
        public: true,
        valid_values: [
          'Amelie Pichard', 'And Re Walker', 'Andrea Incontri', 'Anine Bing',
          'Ann Demeulemeester', 'Anndra Neen', 'Antonio Marras', 'Anya Hindmarch',
          'Area Di Barbara Bologna'
        ],
        searchable: true
      })

      create_custom_attribute(@transactable_type, {
        name: 'retail_value',
        label: 'Retail Value',
        attribute_type: 'string',
        html_tag: 'input',
        required: "0",
        public: true,
        searchable: false,
        wrapper_html_options: { 'data-money-value-container' => true },
        input_html_options: { 'type' => 'number', 'data-money-value' => true }
      })

      create_custom_attribute(@transactable_type, {
        name: 'bond_value',
        label: 'Bond Value',
        attribute_type: 'integer',
        html_tag: 'input',
        required: "1",
        public: true,
        searchable: false,
        wrapper_html_options: { 'data-money-value-container' => true },
        input_html_options: { 'type' => 'number', 'data-money-value' => true }
      })

      create_custom_attribute(@transactable_type, {
        name: 'dry_cleaning',
        label: 'Dry Cleaning',
        attribute_type: 'string',
        html_tag: 'select',
        required: "0",
        public: true,
        valid_values: ['By Lender', 'By Borrower'],
        searchable: false
      })

      # create_custom_attribute(@transactable_type, {
      #   name: 'shipping_cost',
      #   label: 'Dry Cleaning',
      #   attribute_type: 'string',
      #   html_tag: 'select',
      #   required: "0",
      #   public: true,
      #   valid_values: ['By Lender', 'By Borrower'],
      #   searchable: false
      # })

      create_custom_attribute(@default_profile_type, {
        name: 'user_alias',
        label: 'Alias',
        attribute_type: 'string',
        html_tag: 'input',
        required: "1",
        public: true,
        searchable: false
      })

      create_custom_attribute(@default_profile_type, {
        name: 'use_alias_as_name',
        label: 'Use instead of Full Name',
        attribute_type: 'boolean',
        html_tag: 'check_box',
        required: "0",
        public: true
      })

      create_custom_attribute(@default_profile_type, {
        name: 'facebook_url',
        label: 'Facebook URL',
        attribute_type: 'string',
        html_tag: 'input',
        required: "0",
        public: true
      })

      create_custom_attribute(@default_profile_type, {
        name: 'google_url',
        label: 'Google+ URL',
        attribute_type: 'string',
        html_tag: 'input',
        required: "0",
        public: true
      })

     create_custom_attribute(@default_profile_type, {
        name: 'instagram_url',
        label: 'Instagram URL',
        attribute_type: 'string',
        html_tag: 'input',
        required: "0",
        public: true
      })

     create_custom_attribute(@default_profile_type, {
        name: 'twitter_url',
        label: 'Twitter URL',
        attribute_type: 'string',
        html_tag: 'input',
        required: "0",
        public: true
      })

      create_custom_attribute(@default_profile_type, {
        name: 'pinterest_url',
        label: 'Pinterest URL',
        attribute_type: 'string',
        html_tag: 'input',
        required: "0",
        public: true
      })

    end


    def create_categories!
    end


    def create_or_update_form_components!
      TransactableType.first.form_components.destroy_all

      component = TransactableType.first.form_components.where(form_type: 'space_wizard').first_or_initialize
      component.name = 'Fill out the information below'
      component.form_fields = [
        { "user" => "name" },
        { "user" => "user_alias" },
        { "user" => "use_alias_as_name" },
        { "location" => "address" },
        { "user" => "mobile_phone" },
        { "transactable" => "name" },
        { "transactable" => "photos" },
        { "transactable" => "description" },
        { "transactable" => "item_type" },
        { "transactable" => "item_style_accessories" },
        { "transactable" => "item_style_bag" },
        { "transactable" => "item_style_dress" },
        { "transactable" => "item_style_milinery" },
        { "transactable" => "item_style_outerwear" },
        { "transactable" => "dress_size" },
        { "transactable" => "milinery_size" },
        { "transactable" => "outerwear_size" },
        { "transactable" => "dress_length" },
        { "transactable" => "color" },
        { "transactable" => "designer_name" },
        { "transactable" => "price" },
        { "transactable" => "retail_value" },
        { "transactable" => "bond_value" },
        { "transactable" => "dry_cleaning" },
        { "transactable" => "shipping_profile" },
        { "transactable" => "tags" }
      ]
      component.save!
      component = TransactableType.first.form_components.where(form_type: 'transactable_attributes').first_or_initialize
      component.name = 'Details'
      component.form_fields = [
        { "transactable" => "name" },
        { "transactable" => "location_id" },
        { "transactable" => "photos" },
        { "transactable" => "description" },
        { "transactable" => "item_type" },
        { "transactable" => "item_style_accessories" },
        { "transactable" => "item_style_bag" },
        { "transactable" => "item_style_dress" },
        { "transactable" => "item_style_milinery" },
        { "transactable" => "item_style_outerwear" },
        { "transactable" => "dress_size" },
        { "transactable" => "milinery_size" },
        { "transactable" => "outerwear_size" },
        { "transactable" => "dress_length" },
        { "transactable" => "color" },
        { "transactable" => "designer_name" },
        { "transactable" => "price" },
        { "transactable" => "retail_value" },
        { "transactable" => "bond_value" },
        { "transactable" => "unavailable_periods" },
        { "transactable" => "dry_cleaning" },
        { "transactable" => "shipping_profile" },
        { "transactable" => "tags" }
      ]
      component.save!

      component = @default_profile_type.form_components.where(form_type: 'instance_profile_types').first_or_initialize
      component.form_fields = [
        { "user" => "name" },
        { "user" => "user_alias" },
        { "user" => "use_alias_as_name" },
        { "user" => "password" },
        { "user" => "email" },
        { "user" => "mobile_phone" },
        { "user" => "facebook_url" },
        { "user" => "google_url" },
        { "user" => "instagram_url" },
        { "user" => "twitter_url" },
        { "user" => "pinterest_url" },
      ]

      component.save!
    end

    def create_workflow_alerts
    end

    def set_theme_options
      theme = @instance.theme

      theme.color_green = '#4fc6e1'
      theme.color_blue = '#05caf9'
      theme.color_red = '#e83d33'
      theme.color_orange = '#ff8d00'
      theme.color_gray = '#333333'
      theme.color_black = '#171717'
      theme.color_white = '#ffffff'
      theme.call_to_action = 'Learn more'

      theme.contact_email = 'support@thevolte.com'

      theme.facebook_url = 'https://facebook.com'
      theme.twitter_url = 'https://twitter.com'
      theme.gplus_url = 'https://plus.google.com'
      theme.instagram_url = 'https://www.instagram.com'
      theme.youtube_url = 'https://www.youtube.com'
      theme.blog_url = '/blog'
      theme.linkedin_url = 'https://www.linkedin.com'

    #   theme.remote_favicon_image_url = 'https://d2rw3as29v290b.cloudfront.net/instances/195/uploads/ckeditor/picture/data/2760/favicon.png'
    #   theme.remote_icon_retina_image_url = 'https://d2rw3as29v290b.cloudfront.net/instances/195/uploads/ckeditor/picture/data/2761/apple-touch-icon-60_2x.png'

      theme.updated_at = Time.now
      theme.save!
    end

    def create_pages
      puts "\nCreating pages:"
      templates = get_templates_from_dir(File.join(@theme_path, 'pages'))
      templates.each do |template|
        create_page(template.name, template.body)
        puts "\t- #{template.name}"
      end
    end

    def create_content_holders
      puts "\nCreating content holders:"

      templates = get_templates_from_dir(File.join(@theme_path, 'content_holders'), {
        inject_pages: 'any_page',
        position: 'head_bottom'
      })

      templates.each do |template|
        create_content_holder(template.name, template.body, template.inject_pages, template.position)
        puts "\t- #{template.name}"
      end
    end

    def create_mailers
      puts "\nCreating mailers:"
      templates = get_templates_from_dir(File.join(@theme_path, 'mailers'))
      templates.each do |template|
        create_email(template.liquid_path, template.body)
        puts "\t- #{template.name}"
      end
    end

    def create_smses
      puts "\nCreating smses:"
      templates = get_templates_from_dir(File.join(@theme_path, 'sms'))
      templates.each do |template|
        create_email(template.liquid_path, template.body)
        puts "\t- #{template.name}"
      end
    end

    def create_liquid_views
      puts "\nCreating liquid views:"

      templates = get_templates_from_dir(File.join(@theme_path, 'liquid_views'), {
        partial: true
      })

      templates.each do |template|
        create_liquid_view(template.liquid_path, template.body, template.partial)
        puts "\t- #{template.name}"
      end
    end

    # TODO: This should support multiple locales
    def create_translations
      puts "\nTranslating:"

      transformation_hash = {
        # 'reservation' => 'offer',
        # 'Reservation' => 'Offer',
        # 'booking' => 'offer',
        # 'Booking' => 'Offer',
        'host' => 'Lender',
        'Host' => 'Lender',
        'guest' => 'Borrower',
        'Guest' => 'Borrower',
        'this listing' => 'your Item',
        'that listing' => 'your Item',
        'This listing' => 'Your Item',
        'That listing' => 'Your Item',
        # 'listing' => 'Item'
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
            print '.'
            $stdout.flush
          end
        end
      end

      locales = YAML.load_file(File.join(@theme_path, 'translations', 'en.yml'))

      if (locales['en'] != nil)
        locales_hash = convert_hash_to_dot_notation(locales['en'])

        locales_hash.each_pair do |key, value|
          create_translation(key, value, 'en')
          print '.'
          $stdout.flush
        end
      end

      puts "\n"
    end


    def expire_cache
      puts "\nClearing cache..."
      CacheExpiration.send_expire_command 'InstanceView', instance_id: @instance.id
      CacheExpiration.send_expire_command 'Translation', instance_id: @instance.id
      CacheExpiration.send_expire_command 'CustomAttribute', instance_id: @instance.id
      Rails.cache.clear
    end


    private

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

      def get_templates_from_dir(template_folder, defaults = {})
        template_files = Dir.entries(template_folder).select{ |e| File.file?(File.join(template_folder, e)) && e != '.keep' }
        template_files.map! { |filename| load_file_with_yaml_front_matter(File.join(template_folder, filename), defaults) }
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

      def create_page(path, body)
        slug = path.parameterize
        page = @instance.theme.pages.where(slug: slug).first_or_initialize
        page.path = path
        page.content = body
        page.save
      end

      def create_content_holder(name, body, inject_pages, position)
        inject_pages = [inject_pages] if inject_pages.kind_of?(String)
        ch = @instance.theme.content_holders.where(
          name: name
        ).first_or_initialize

        ch.update!({
          content: body,
          inject_pages: inject_pages,
          position: position
        })
      end

      def create_translation(key, value, locale)
        @instance.translations.where(
          locale: locale,
          key: key
        ).first_or_initialize.update!(value: value)
      end

      def create_liquid_view(path, body, partial)
        iv = InstanceView.where(
          instance_id: @instance.id,
          path: path,
        ).first_or_initialize
        iv.update!({
          transactable_types: TransactableType.all,
          body: body,
          format: 'html',
          handler: 'liquid',
          partial: partial,
          view_type: 'view',
          locales: Locale.all
        })
      end

      def load_file_with_yaml_front_matter(path, config = {})
        body = File.read(path)
        regex = /\A---(.|\n)*?---\n/

        # search for YAML front matter
        yfm = body.match(regex)
        if yfm
          config = config.merge(YAML.load(yfm[0]))
          body.gsub!(regex, '')
        end
        config = config.merge({ body: body })

        config["liquid_path"] ||= File.basename(path, '.*').gsub('--','/')
        config["name"] ||= File.basename(path, '.*').gsub('--','/').humanize.titleize
        config["path"] ||= path

        OpenStruct.new(config)
      end

      def create_custom_attribute(object, hash)
          hash = hash.with_indifferent_access
          attr = object.custom_attributes.where({
            name: hash.delete(:name)
          }).first_or_initialize
          attr.assign_attributes(hash)
          attr.set_validation_rules!
      end

  end

end
